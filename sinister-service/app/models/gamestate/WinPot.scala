package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class WinPot(
    seatIndex: Int,
    sidePotIndex: Int,
    winAmount: Int
) extends GameStateEvent
    with AppliesToPlayer
    with GameNarrative
    with HandEvent {
  val isSidePot: Boolean = sidePotIndex > 0
}

object WinPot {
  implicit val encoder: Encoder.AsObject[WinPot] = deriveEncoder
  implicit val decoder: Decoder[WinPot] = deriveDecoder
}
