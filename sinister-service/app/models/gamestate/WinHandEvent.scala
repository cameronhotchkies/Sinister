package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

case class WinHandEvent(
    seatIndex: Int,
    amount: Int,
    rawHandDetail: String
) extends GameStateEvent
    with AppliesToPlayer
    with GameNarrative {
  override def encoded: Json = WinHandEvent.encoder(this)

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

object WinHandEvent {
  implicit val encoder: Encoder[WinHandEvent] = (a: WinHandEvent) => {
    val encoder = deriveEncoder[WinHandEvent]
      .encodeObject(a)
      .add("handRank", Json.fromString(a.extrapolateHandRank()))
    Json.fromJsonObject(encoder)
  }
  implicit val decoder: Decoder[WinHandEvent] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        amount <- c.downField("amount").as[Int]
        rawHandDetail <- c.downField("hcm").as[String]
      } yield WinHandEvent(seatIndex, amount, rawHandDetail)
    }
}
