package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class SubtractChipsFromStack(seatIndex: Int, subtractChips: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with HandEvent {}

object SubtractChipsFromStack {
  implicit val encoder: Encoder.AsObject[SubtractChipsFromStack] = deriveEncoder
  implicit val decoder: Decoder[SubtractChipsFromStack] = deriveDecoder
}
