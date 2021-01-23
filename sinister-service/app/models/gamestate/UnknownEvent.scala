package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Encoder, Json}

case class UnknownEvent(unknownEventType: Int, raw: Json)
    extends GameStateEvent
    with GameNarrative {
  def encoded: Json = UnknownEvent.encoded(this)
}

object UnknownEvent {
  implicit val encoded: Encoder[UnknownEvent] = deriveEncoder
}
