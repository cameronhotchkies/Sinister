package actors

import actors.TableRegistry.TableById
import akka.actor.{Actor, ActorRef, Props}
import cats.data.OptionT
import io.circe.Json
import models.gamestate.DealCommunityCard
import models.importer.GameState.toHandState
import models.importer.GameStateEvent.{bettingRoundFor, toHandEvent}
import models.importer.GameStateMessage
import models.{GameStateAddition, Hand, Table}
import play.api.Logger
import play.libs.Scala.emptyMap

import java.time.Instant
import javax.inject.{Inject, Named}
import scala.concurrent.{ExecutionContext, Future}

case class IntakeGamestate(
    gameId: Int,
    gamestateData: Json
)

class GamestateCollector @Inject() (
    @Named("table-registry") val tableRegistry: ActorRef
) extends Actor {
  override def receive: Receive = {
    case IntakeGamestate(gameId, content) => {
      val childName = s"game-${gameId}"

      val target = context
        .child(childName)
        .getOrElse {
          val newChild =
            context.actorOf(Props(new ActiveHand(tableRegistry)), childName)
          newChild ! ActivateHand(gameId)
          newChild
        }

      target ! RawGamestate(content)
    }
  }
}

case class CheckForCompletion()
case class SummarizeHand()

class ActiveHand(val tableRegistry: ActorRef) extends Actor {
  val logger: Logger = Logger("application")

  val initializationTime = Instant.now()

  def active(
      gameId: Int,
      states: List[Json],
      gameTable: Option[Table]
  ): Receive = {
    case RawGamestate(content) => {
      val newStates = states :+ content
      logger.debug(s"Tracking ${newStates.length} states for $gameId")
      context become active(gameId, newStates, gameTable)
      self ! CheckForCompletion()
    }
    case CheckForCompletion() => {
      logger.debug(s"Table Defined: ${gameTable.isDefined}")
      val mostRecent = states.last
      val gsm = mostRecent.as[GameStateMessage]
      gsm.map(gssm => {
        logger.debug(s"GSSM TS: ${gssm.ts}")

        if (gssm.gameState.additionalData.stage == GameStateAddition.GameOver) {
          self ! SummarizeHand()
        }

        if (gameTable.isEmpty) {
          val tableId = gssm.gameState.tableId
          tableRegistry ! TableById(tableId)
        }
      })
    }
    case SummarizeHand() => {
      val messages = states.map(_.as[GameStateMessage])

      val startingChips = messages
        .collectFirst {
          case Right(result) => result
        }
        .map(gameStateMessage =>
          gameStateMessage.gameState.handPlayers.flatten.map { player =>
            player.name -> player.startingChips
          }.toMap
        )
        .getOrElse(emptyMap())

      val handStates = messages
        .flatMap(m => m.toOption.map(gsm => toHandState(gsm.gameState)))

      val events =
        messages.flatMap(gssm => gssm.map(_.events).getOrElse(Nil))

      implicit val ec: ExecutionContext = context.dispatcher
      val gameTableContent = OptionT(Future.successful(gameTable))

      val handSummary = Hand.summarize(
        gameId,
        handStates,
        events.map(toHandEvent),
        initializationTime,
        startingChips,
        gameTableContent
      )

      handSummary.map { hs =>
        logger.debug(s"HandSummary: $hs")
      }
    }

    case Some(t: Table) => {
      context become active(gameId, states, Some(t))
    }
  }

  // Probably unused path
  def augmentIfNeeded(gameStateMessage: GameStateMessage) = {
    val events = gameStateMessage.events
    val augmenting = events.exists(_.isInstanceOf[DealCommunityCard])

    val bettingRound = bettingRoundFor(
      gameStateMessage.gameState.additionalData.stage,
      gameStateMessage.gameState.dealer.cards
    )
  }

  override def receive: Receive = {
    case ActivateHand(gameId) => {
      logger.debug(s"activating ${gameId}")
      context become active(gameId, Nil, None)
    }
  }
}

case class ActivateHand(gameId: Int)
case class RawGamestate(value: Json)
