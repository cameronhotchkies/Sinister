package models

import cats.data.OptionT
import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.Hand.logger
import models.gamestate._
import models.gamestate.playeraction.{
  BigBlind,
  Call,
  MuckCards,
  Raise,
  ShowCards,
  SmallBlind
}
import play.api.Logger

import java.time.Instant
import scala.concurrent.{ExecutionContext, Future}

case class Hand(
    handId: Int,
    seatedPlayers: Seq[Option[HandPlayer]],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card],
    events: Seq[HandEvent],
    stages: List[Int],
    startDate: Instant,
    table: Option[Table]
) {
  val bigBlind: Option[HandPlayer] = {
    val bigBlindAction = events.collectFirst {
      case bb: BigBlind => bb
    }

    val bbEvents = events.filter(_.isInstanceOf[BigBlind])
    if (bbEvents.length > 1) {
      // logger.info(s"Too many (${bbEvents.length}) bb: $handId")
      // logger.info(s"BBE: ${bbEvents}")
      // this could be extra or dead blinds?

    }

    bigBlindAction.flatMap(bba => seatedPlayers(bigBlindIndex))
  }
  val smallBlind: Option[HandPlayer] = {
    val smallBlindAction = events.collectFirst {
      case sb: SmallBlind => sb
    }

    smallBlindAction.flatMap(sba => seatedPlayers(sba.seatIndex))
  }

  lazy val showdownOccurred: Boolean = {
    val showingEvents = events.filter {
      case ShowCards(_) => true
      case ShowHand(_)  => true
      case _            => false
    }

    val (showCards, showHands) =
      showingEvents.partition(_.isInstanceOf[ShowCards])

    val showCardCount = showCards.length
    val showHandCount = showHands.length
    if (showCardCount != showHandCount) {
      logger.info(
        s"[!] Unexpected show event imbalance: $handId ($showCardCount : $showHandCount)"
      )
    } else if (showingEvents.nonEmpty && !stages.contains(4)) {
      // logger.info(s"[!] Showing odd stages for $handId: ${stages}")
    }

    // logger.info(s"Showing events: ${showingEvents}")

    // Mucks can leave it at 2
    showingEvents.length >= 2
  }

  val playersDealtIn: Seq[String] = events
    .filter { event => event.isInstanceOf[DealPlayerCard] }
    .map(_.asInstanceOf[AppliesToPlayer].seatIndex)
    .distinct
    .flatMap(
      seatedPlayers(_)
        .map(_.name)
    )

  def positionForPlayer(playerName: String): Int = {
    seatedPlayers.indexWhere(_.exists(_.name == playerName))
  }

  lazy val preflopEvents: Seq[HandEvent] =
    events.takeWhile(!_.isInstanceOf[BettingCompleted])

  val playersInvolvedInShowdown: Seq[Int] = {
    if (showdownOccurred) {
      events
        .filter { event =>
          {
            val cardShowingBehavior =
              event.isInstanceOf[ShowCards] || event.isInstanceOf[MuckCards]
            cardShowingBehavior
          }
        }
        .map(event => {
          event.asInstanceOf[AppliesToPlayer].seatIndex
        })
    } else {
      Nil
    }
  }

  def winners(): Seq[String] = {
    val winningPlayers = events
      .filter(_.isInstanceOf[WinHand])
      .map(_.asInstanceOf[WinHand].seatIndex)
      .distinct
      .map(seatedPlayers(_).get.name)

    winningPlayers
  }

  def voluntaryParticipants() = {
    val voluntaryPositions = preflopEvents.collect {
      case Call(position, _)  => position
      case Raise(position, _) => position
    }.distinct

    voluntaryPositions.flatMap { qq => seatedPlayers(qq).map(_.name) }
  }

  def preflopRaisers() = {
    val raisingPositions = preflopEvents.collect {
      case Raise(position, _) => position
    }.distinct

    raisingPositions.flatMap { qq => seatedPlayers(qq).map(_.name) }
  }

  val isComplete: Boolean = {
    val phases = stages.count(_ == 0)

    if (phases < 2) false
    else if (phases == 2) {
      if (bigBlind.isEmpty) {
        // missing big blind is indicative of a corrupt hand parse
        false
      } else {
        // more can come here
        true
      }
    } else ???
  }

  protected def unapply()
      : (Int, Seq[Option[HandPlayer]], Option[HandPlayer], Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object Hand {
  val logger: Logger = Logger("application")

  def summarize(
      gameId: Int,
      handStates: Seq[HandState],
      handEvents: Seq[HandEvent],
      startTime: Instant,
      startingChipsByPlayer: Map[String, Int],
      table: OptionT[Future, Table]
  )(implicit ec: ExecutionContext): Future[Hand] = {
    val dealerSummary = handStates
      .map(_.dealer)
      .reduce((l, r) => {
        l.merge(r)
      })

    val playerSummary = summarizePlayers(handStates)
      .map(_.map { player =>
        {
          val correctChips = startingChipsByPlayer.getOrElse(player.name, 0)
          player.copy(startingChips = correctChips)
        }
      })

    val bigBlinders = handStates.map(_.bigBlindIndex).distinct
    val smallBlinders = handStates.map(_.smallBlindIndex).distinct

    val stages = handStates
      .map(_.additionalData.stage)
      .foldLeft[List[Int]](Nil) { (acc, stage) =>
        {
          acc match {
            case Nil                  => acc :+ stage
            case _ :+ t if t == stage => acc
            case _                    => acc :+ stage
          }
        }
      }

//    assert(bigBlinders.length == 1)
//    assert(smallBlinders.length == 1)
    table.value.map(oTable =>
      Hand(
        gameId,
        playerSummary,
        bigBlinders.head,
        smallBlinders.head,
        dealerSummary.cards,
        handEvents,
        stages,
        startTime,
        oTable
      )
    )

  }

  def summarizePlayers(
      gameStates: Seq[HandState]
  ): Seq[Option[HandPlayer]] = {
    val players = gameStates
      .map(_.handPlayers)
    players.reduce((l, r) => {
      l.lazyZip(r) map {
        case (Some(x), None)    => Option(x)
        case (None, Some(y))    => Option(y)
        case (Some(x), Some(y)) => Option(x.merge(y))
        case (None, None)       => None
      }
    })
  }

  implicit val encoder: Encoder[Hand] = (summary: Hand) => {
    val derived = deriveEncoder[Hand]
      .encodeObject(summary)
      .add(
        "playersInvolvedInShowdown",
        Json.fromValues(
          summary.playersInvolvedInShowdown
            .map(Json.fromInt)
        )
      )
      .add("isComplete", Json.fromBoolean(summary.isComplete))

    Json.fromJsonObject(derived)
  }

  implicit val decoder: Decoder[Hand] = deriveDecoder
}
