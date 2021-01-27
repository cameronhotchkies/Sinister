package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class DealCommunityCard(seatIndex: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with HandEvent {}

object DealCommunityCard {
  implicit val encoder: Encoder.AsObject[DealCommunityCard] = deriveEncoder
  implicit val decoder: Decoder[DealCommunityCard] = deriveDecoder
}
