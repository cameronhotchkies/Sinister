package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.importer.GameStateEvent

case class WinHand(
    seatIndex: Int,
    amount: Int,
    rawHandDetail: String
) extends GameStateEvent
    with AppliesToPlayer
    with GameNarrative
    with HandEvent {

  def extrapolateHandRank(): String = {
    if (rawHandDetail.nonEmpty) {
      rawHandDetail.charAt(0) match {
        case 'A' => "?? Royal Flush ??"
        case 'B' => "?? Straight Flush ??"
        case 'C' => "?? Four of a Kind ??"
        case 'D' => "Full House"
        case 'E' => "Flush"
        case 'F' => "Straight"
        case 'G' => "Three of a Kind"
        case 'H' => "Two Pair"
        case 'I' => "Pair"
        case 'J' => "High Card"
        case _   => "???"
      }
    } else "n/a"
  }
}

object WinHand {
  implicit val encoder: Encoder.AsObject[WinHand] = (a: WinHand) => {
    val encoder = deriveEncoder[WinHand]
      .encodeObject(a)
      .add("handRank", Json.fromString(a.extrapolateHandRank()))

    Json.fromJsonObject(encoder).asObject.get
  }

  implicit val decoder: Decoder[WinHand] = deriveDecoder
}
