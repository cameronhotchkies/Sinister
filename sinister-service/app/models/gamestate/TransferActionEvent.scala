package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

case class TransferActionEvent(actionToSeat: Int)
    extends GameStateEvent
    with AppliesToPlayer {
  override val seatIndex: Int = actionToSeat
  override def encoded: Json = TransferActionEvent.encoder(this)
}

object TransferActionEvent {
  implicit val encoder: Encoder[TransferActionEvent] = deriveEncoder

  implicit val decoder: Decoder[TransferActionEvent] =
    (c: HCursor) => {
      for {
        actionTarget <- c.downField("seat-idx").as[Int]
      } yield TransferActionEvent(actionTarget)
    }
}
