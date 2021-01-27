package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class DealPlayerCard(seatIndex: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with HandEvent {}

object DealPlayerCard {
  implicit val encoder: Encoder.AsObject[DealPlayerCard] = deriveEncoder
  implicit val decoder: Decoder[DealPlayerCard] = deriveDecoder
}
