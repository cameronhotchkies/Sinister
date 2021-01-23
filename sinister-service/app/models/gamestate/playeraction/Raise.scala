package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class Raise(seatIndex: Int, amount: Int) extends PlayerAction {
  def encoded: Json = Raise.encoder(this)
}

object Raise {
  implicit val encoder: Encoder[Raise] = Encoder.forProduct2(
    "player",
    "raise"
  )(raise => (raise.seatIndex, raise.amount))
}
