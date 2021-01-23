package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class SmallBlind(seatIndex: Int, amount: Int) extends PlayerAction {
  def encoded: Json = SmallBlind.encoder(this)
}

object SmallBlind {
  implicit val encoder: Encoder[SmallBlind] =
    Encoder.forProduct2("player", "smallBlind")(smallBlind =>
      (smallBlind.seatIndex, smallBlind.amount)
    )
}
