package models.gamestate

import io.circe.{Encoder, Json}

case class DealCommunityCard(seatIndex: Int)
    extends GameStateEvent
    with AppliesToPlayer {
  override def encoded: Json = DealCommunityCard.encoder(this)
}

object DealCommunityCard {
  implicit val encoder: Encoder[DealCommunityCard] = Encoder.forProduct1("dealCommunityCard")(DealCommunityCard.unapply)
}