package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class Bet(seatIndex: Int, amount: Int) extends PlayerAction {
  def encoded: Json = Bet.encoder(this)
}

object Bet {
  implicit val encoder: Encoder[Bet] =
    Encoder.forProduct2("player", "bet")(bet => (bet.seatIndex, bet.amount))
}
