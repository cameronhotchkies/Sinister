package models

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.Hand.logger
import models.gamestate.playeraction.{
  BigBlind,
  MuckCards,
  ShowCards,
  SmallBlind
}
import models.gamestate._
import play.api.Logger

import java.time.Instant

case class Hand(
    handId: Int,
    seatedPlayers: Seq[Option[HandPlayer]],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card],
    events: Seq[HandEvent],
    stages: List[Int],
    startDate: Instant
) {
  val bigBlind: Option[HandPlayer] = {
    val bigBlindAction = events.collectFirst {
      case bb: BigBlind => bb
    }

    val bbcount = events.count(_.isInstanceOf[BigBlind])
    if (bbcount > 1) {
      logger.info(s"Too many ($bbcount) bb: $handId")
    }
    assert(events.count(_.isInstanceOf[BigBlind]) <= 1)

    bigBlindAction.flatMap(bba => seatedPlayers(bba.seatIndex))
  }
  val smallBlind: Option[HandPlayer] = {
    val smallBlindAction = events.collectFirst {
      case sb: SmallBlind => sb
    }

    smallBlindAction.flatMap(sba => seatedPlayers(sba.seatIndex))
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
    events.takeWhile(!_.isInstanceOf[EnterNextStage])

  val playersInvolvedInShowdown: Seq[Int] = events
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

  def winners(): Seq[String] = {
    val winningPlayers = events
      .filter(_.isInstanceOf[WinHand])
      .map(_.asInstanceOf[WinHand].seatIndex)
      .distinct
      .map(seatedPlayers(_).get.name)

    winningPlayers
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
      startTime: Instant
  ): Hand = {
    val dealerSummary = handStates
      .map(_.dealer)
      .reduce((l, r) => {
        l.merge(r)
      })

    val playerSummary = summarizePlayers(handStates)

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

    logger.info(s"Stages: $stages")

    assert(bigBlinders.length == 1)
    assert(smallBlinders.length == 1)

    Hand(
      gameId,
      playerSummary,
      bigBlinders.head,
      smallBlinders.head,
      dealerSummary.cards,
      handEvents,
      stages,
      startTime
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
