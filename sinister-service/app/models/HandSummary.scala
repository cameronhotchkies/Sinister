package models

import io.circe.{Encoder, Json}
import io.circe.generic.semiauto.deriveEncoder
import models.HandSummary.logger
import models.gamestate.{AppliesToPlayer, DealPlayerCard, GameStateEvent}
import models.gamestate.playeraction.{MuckCards, ShowCards}
import play.api.Logger

case class HandSummary(
    handId: Int,
    seatedPlayers: Seq[Option[SeatedPlayer]],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card],
    events: Seq[GameStateEvent],
    stages: List[Int]
) {
  val bigBlind: SeatedPlayer = seatedPlayers(bigBlindIndex).get
  val smallBlind: SeatedPlayer = seatedPlayers(smallBlindIndex).get

  val playersDealtIn: Seq[String] = events
    .filter { event => event.isInstanceOf[DealPlayerCard]}
    .map(_.asInstanceOf[AppliesToPlayer].seatIndex)
    .distinct
    .flatMap(seatedPlayers(_)
      .map(_.name)
    )

  val playersInvolvedInShowdown: Seq[Int] = events.filter{ event => {
    val cardShowingBehavior = event.isInstanceOf[ShowCards] || event.isInstanceOf[MuckCards]
    cardShowingBehavior
  }}
    .map(event => {
      logger.info(s"FE: $event")
      event.asInstanceOf[AppliesToPlayer].seatIndex
    })

  val isComplete: Boolean = {
    val phases = stages.count(_ == 0)

    if (phases < 2) false
    else if (phases == 2) true
    else ???
  }

  protected def unapply()
      : (Int, Seq[Option[SeatedPlayer]], SeatedPlayer, Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object HandSummary {
  val logger = Logger("application")

  def summarize(gameId: Int, gameStates: Seq[GameState], gameEvents: Seq[GameStateEvent]): HandSummary = {
    val dealerSummary = gameStates
      .map(_.dealer)
      .reduce((l, r) => {
        l.merge(r)
      })

    val playerSummary = summarizePlayers(gameStates)

    val bigBlinders = gameStates.map(_.bigBlindIndex).distinct
    val smallBlinders = gameStates.map(_.smallBlindIndex).distinct

    val stages = gameStates
      .map(_.additionalData.stage)
      .foldLeft[List[Int]](Nil) { (acc, stage) => {
        acc match {
          case Nil => acc :+ stage
          case _ :+ t if t == stage => acc
          case _ => acc :+ stage
        }
      }
      }

    logger.info(s"Stages: $stages")

    assert(bigBlinders.length == 1)
    assert(smallBlinders.length == 1)

    HandSummary(
      gameId,
      playerSummary,
      bigBlinders.head,
      smallBlinders.head,
      dealerSummary.cards,
      gameEvents,
      stages
    )
  }

  def summarizePlayers(
                        gameStates: Seq[GameState]
                      ): Seq[Option[SeatedPlayer]] = {
    val players = gameStates
      .map(_.seatedPlayers)
    players.reduce((l, r) => {
      l.lazyZip(r) map {
        case (Some(x), None) => Option(x)
        case (None, Some(y)) => Option(y)
        case (Some(x), Some(y)) => Option(x.merge(y))
        case (None, None) => None
      }
    })
  }

  implicit val encoder: Encoder[HandSummary] = (summary: HandSummary) => {
    logger.info(s"PL in SD: ${summary.playersInvolvedInShowdown}")
    val derived = deriveEncoder[HandSummary]
      .encodeObject(summary)
      .add(
        "playersInvolvedInShowdown",
        Json.fromValues(
          summary.playersInvolvedInShowdown
            .map(Json.fromInt))
      )
      .add("isComplete", Json.fromBoolean(summary.isComplete))
      .remove("events")

    logger.info(s"Derived: $derived"  )

    Json.fromJsonObject(derived)
  }


}
