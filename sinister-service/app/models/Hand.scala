package models

import io.circe.{Decoder, Encoder, Json}
import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import models.Hand.logger
import models.gamestate.{AppliesToPlayer, DealPlayerCard, HandEvent, WinHand}
import models.gamestate.playeraction.{MuckCards, ShowCards}
import play.api.Logger

case class Hand(
    handId: Int,
    seatedPlayers: Seq[Option[HandPlayer]],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card],
    events: Seq[HandEvent],
    stages: List[Int]
) {
  val bigBlind: HandPlayer = seatedPlayers(bigBlindIndex).get
  val smallBlind: HandPlayer = seatedPlayers(smallBlindIndex).get

  val playersDealtIn: Seq[String] = events
    .filter { event => event.isInstanceOf[DealPlayerCard] }
    .map(_.asInstanceOf[AppliesToPlayer].seatIndex)
    .distinct
    .flatMap(
      seatedPlayers(_)
        .map(_.name)
    )

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
    events
      .filter(_.isInstanceOf[WinHand])
      .map(_.asInstanceOf[WinHand].seatIndex)
      .distinct
      .map(seatedPlayers(_).get.name)
  }

  val isComplete: Boolean = {
    val phases = stages.count(_ == 0)

    if (phases < 2) false
    else if (phases == 2) true
    else ???
  }

  protected def unapply(): (Int, Seq[Option[HandPlayer]], HandPlayer, Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object Hand {
  val logger: Logger = Logger("application")

  def summarize(
      gameId: Int,
      handStates: Seq[HandState],
      handEvents: Seq[HandEvent]
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
      stages
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
      .remove("events")

    Json.fromJsonObject(derived)
  }

  implicit val decoder: Decoder[Hand] = deriveDecoder

}
