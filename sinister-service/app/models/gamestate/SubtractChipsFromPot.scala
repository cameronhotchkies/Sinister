package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class SubtractChipsFromPot(seatIndex: Int, sidePotIndex: Int, amount: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with HandEvent {}

object SubtractChipsFromPot {
  implicit val encoder: Encoder.AsObject[SubtractChipsFromPot] = deriveEncoder
  implicit val decoder: Decoder[SubtractChipsFromPot] = deriveDecoder
}
