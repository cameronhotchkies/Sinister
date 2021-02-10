package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.importer.GameStateEvent

case class UnknownEvent(unknownEventType: Int, raw: Json)
    extends GameStateEvent
    with GameNarrative
with HandEvent {
  def encoded: Json = UnknownEvent.encoded(this)
}

object UnknownEvent {
  implicit val encoded: Encoder.AsObject[UnknownEvent] = deriveEncoder
  implicit val decoder: Decoder[UnknownEvent] = deriveDecoder
}
