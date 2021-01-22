package models

import io.circe.Encoder
import io.circe.generic.semiauto.deriveEncoder

case class HandSummary(
    handId: Int,
    seatedPlayers: Seq[Option[SeatedPlayer]],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card],
    events: Seq[GameStateEvent]
) {
  val bigBlind: SeatedPlayer = seatedPlayers(bigBlindIndex).get
  val smallBlind: SeatedPlayer = seatedPlayers(smallBlindIndex).get
  protected def unapply()
      : (Int, Seq[Option[SeatedPlayer]], SeatedPlayer, Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object HandSummary {
  def summarize(gameId: Int, gameStates: Seq[GameState]): HandSummary = {
    val dealerSummary = gameStates
      .map(_.dealer)
      .reduce((l, r) => {
        l.merge(r)
      })

    val playerSummary = summarizePlayers(gameStates)

    val bigBlinders = gameStates.map(_.bigBlindIndex).distinct
    val smallBlinders = gameStates.map(_.smallBlindIndex).distinct

    assert(bigBlinders.length == 1)
    assert(smallBlinders.length == 1)

    HandSummary(
      gameId,
      playerSummary,
      bigBlinders.head,
      smallBlinders.head,
      dealerSummary.cards,
      Nil
    )
  }

  def summarizePlayers(
      gameStates: Seq[GameState]
  ): Seq[Option[SeatedPlayer]] = {
    val players = gameStates
      .map(_.seatedPlayers)
    players.reduce((l, r) => {
      l.lazyZip(r) map {
        case (Some(x), None)    => Option(x)
        case (None, Some(y))    => Option(y)
        case (Some(x), Some(y)) => Option(x.merge(y))
        case (None, None)       => None
      }
    })
  }

  implicit val encoder: Encoder[HandSummary] = deriveEncoder
}
