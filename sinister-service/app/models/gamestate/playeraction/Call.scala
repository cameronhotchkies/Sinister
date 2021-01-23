package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class Call(seatIndex: Int, amount: Int) extends PlayerAction {
  def encoded: Json = Call.encoder(this)
}

object Call {
  implicit val encoder: Encoder[Call] =
    Encoder.forProduct2("player", "call")(call => (call.seatIndex, call.amount))
}
