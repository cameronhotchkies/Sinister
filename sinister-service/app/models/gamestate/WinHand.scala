package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.{Card, HandPlayer}
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
      val rawCards = rawHandDetail
        .split("\\.")
        .drop(1).head
        .split(";")
        .map(_.toInt).map(Card.apply)
      val overallResult = rawHandDetail.charAt(0) match {
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
      s"$overallResult + [${rawCards.map(_.readable).mkString(" ")}]"
    } else "n/a"
  }

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    seats(seatIndex).fold(s"A spectral cheat absconds with ${amount/100.00} chips"){ player =>
      f"${player.name} wins ${amount/100.0}%.2f chips with ${extrapolateHandRank()}"
    }
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
