package models.gamestate

import io.circe.{Encoder, Json}

case class ShowHand(seatIndex: Int)
    extends GameStateEvent
    with GameNarrative
    with AppliesToPlayer {
  override def encoded: Json = ShowHand.encoder(this)
}

object ShowHand {
  implicit val encoder: Encoder[ShowHand] =
    Encoder.forProduct1("showHand")(ShowHand.unapply)
}
