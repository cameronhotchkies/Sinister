package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class TransferAction(actionToSeat: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with HandEvent {
  override val seatIndex: Int = actionToSeat
}

object TransferAction {
  implicit val encoder: Encoder.AsObject[TransferAction] = deriveEncoder
  implicit val decoder: Decoder[TransferAction] = deriveDecoder
}
