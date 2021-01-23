package models.gamestate

import io.circe.{Encoder, Json}

case class DealPlayerCard(seatIndex: Int)
    extends GameStateEvent
    with AppliesToPlayer {
  override def encoded: Json = DealPlayerCard.encoder(this)
}

object DealPlayerCard {
  implicit val encoder: Encoder[DealPlayerCard] = Encoder.forProduct1(
    "dealCard"
  )(DealPlayerCard.unapply)
}
