package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

case class WinPotEvent(
    seatIndex: Int,
    sidePotIndex: Int,
    winAmount: Int
) extends GameStateEvent
    with AppliesToPlayer
    with GameNarrative {
  val isSidePot: Boolean = sidePotIndex > 0
  override def encoded: Json = WinPotEvent.encoder(this)
}

object WinPotEvent {
  implicit val encoder: Encoder[WinPotEvent] = deriveEncoder
  implicit val decoder: Decoder[WinPotEvent] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        sidePotIndex <- c.downField("action").as[Int]
        amount <- c.downField("amount").as[Int]
      } yield WinPotEvent(seatIndex, sidePotIndex, amount)
    }
}
