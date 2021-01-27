package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class TransferButton(buttonToSeat: Int)
    extends GameStateEvent
    with GameNarrative
    with HandEvent {}

object TransferButton {
  implicit val encoder: Encoder.AsObject[TransferButton] = deriveEncoder
  implicit val decoder: Decoder[TransferButton] = deriveDecoder
}
