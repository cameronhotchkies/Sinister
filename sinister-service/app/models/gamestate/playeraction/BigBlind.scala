package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class BigBlind(seatIndex: Int, amount: Int) extends PlayerAction {
  def encoded: Json = BigBlind.encoder(this)
}

object BigBlind {
  implicit val encoder: Encoder[BigBlind] =
    Encoder.forProduct2("player", "bigBlind")(bigBlind =>
      (bigBlind.seatIndex, bigBlind.amount)
    )
}
