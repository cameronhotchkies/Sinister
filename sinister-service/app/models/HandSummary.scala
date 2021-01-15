package models

import play.api.libs.json.{Format, Json, Reads, Writes}

case class HandSummary(
    handId: Int,
    seatedPlayers: Seq[SeatedPlayer],
    bigBlindIndex: Int,
    smallBlindIndex: Int,
    board: Seq[Card]
) {
  val bigBlind: SeatedPlayer = seatedPlayers(bigBlindIndex)
  val smallBlind: SeatedPlayer = seatedPlayers(smallBlindIndex)
  protected def unapply(): (Int, Seq[SeatedPlayer], SeatedPlayer, Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object HandSummary {
  def summarize(gameId: Int, gameStates: Seq[GameState]): HandSummary = {
    val dealerSummary = gameStates.map(_.dealer).reduce((l,r) => {
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
      dealerSummary.cards
    )
  }

  def summarizePlayers(gameStates: Seq[GameState]): Seq[SeatedPlayer] = {
    val players = gameStates
      .map(_.seatedPlayers)
    players.reduce((l, r) => {
      l.lazyZip(r) map (_.merge(_))
    })
  }

  implicit val writes: Writes[HandSummary] = (handDetail: HandSummary) => {
    Json.obj(
      "handId" -> handDetail.handId,
      "seatedPlayers" -> handDetail.seatedPlayers,
      "bigBlind" -> handDetail.bigBlind,
      "smallBlind" -> handDetail.smallBlind,
      "board" -> handDetail.board
    )
  }
}
