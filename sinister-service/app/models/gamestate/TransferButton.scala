package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.importer.GameStateEvent

case class TransferButton(buttonToSeat: Int)
    extends GameStateEvent
    with GameNarrative
    with HandEvent {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    seats(buttonToSeat).fold(s"The house dealer steps in at position $buttonToSeat"){ player =>
      s"${player.name} is now the dealer"
    }
  }
}

object TransferButton {
  implicit val encoder: Encoder.AsObject[TransferButton] = deriveEncoder
  implicit val decoder: Decoder[TransferButton] = deriveDecoder
}
