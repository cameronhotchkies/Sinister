package models

import play.api.libs.json.{Format, Json, Reads, Writes}

case class HandSummary(
    handId: Int,
    seatedPlayers: Seq[SeatedPlayer],
    bigBlindIndex: Int,
    smallBlindIndex: Int
) {
  val bigBlind: SeatedPlayer = seatedPlayers(bigBlindIndex)
  val smallBlind: SeatedPlayer = seatedPlayers(smallBlindIndex)
  protected def unapply(): (Int, Seq[SeatedPlayer], SeatedPlayer, Int) = {
    (handId, seatedPlayers, bigBlind, smallBlindIndex)
  }
}
object HandSummary {
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
      "smallBlind" -> handDetail.smallBlind
    )
  }

  implicit val reads: Reads[HandSummary] = Json.reads[HandSummary]
  implicit val format: Format[HandSummary] = Format(reads, writes)
}
