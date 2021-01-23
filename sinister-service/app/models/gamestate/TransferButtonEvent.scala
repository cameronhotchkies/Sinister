package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

case class TransferButtonEvent(buttonToSeat: Int)
    extends GameStateEvent
    with GameNarrative {
  override def encoded: Json = TransferButtonEvent.encoder(this)
}

object TransferButtonEvent {
  implicit val encoder: Encoder[TransferButtonEvent] = deriveEncoder

  implicit val decoder: Decoder[TransferButtonEvent] =
    (c: HCursor) => {
      for {
        actionTarget <- c.downField("seat-idx").as[Int]
      } yield TransferButtonEvent(actionTarget)
    }
}
