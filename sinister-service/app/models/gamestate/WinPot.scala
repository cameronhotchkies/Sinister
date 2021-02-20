package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
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

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    seats(seatIndex).fold(s"A questionable entity dissipates with ${winAmount/100.00} chips"){ player =>
      f"${player.name} wins Pot #$sidePotIndex of ${winAmount/100.0}%.2f chips"
    }
  }
}

object WinPot {
  implicit val encoder: Encoder.AsObject[WinPot] = deriveEncoder
  implicit val decoder: Decoder[WinPot] = deriveDecoder
}
