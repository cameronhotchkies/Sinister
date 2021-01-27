package models

import io.circe.{Decoder, Encoder, Json}
import io.circe.generic.semiauto.deriveDecoder

case class Card(ordinal: Int) {
  val faceDown: Boolean = ordinal == -1

  def readable: String = {
    if (ordinal < 0) {
      "Xx"
    } else {
      val rank = Card.Ranks(ordinal / 4)
      val suit = Card.Suits(ordinal % 4)

      s"$rank$suit"
    }
  }
}

object Card {
  implicit val decoder: Decoder[Card] = deriveDecoder

  def deserialize(cardData: String): Seq[Card] = {
    if (cardData != "-1;-1") {
      cardData.split(";")
        .filter(_.nonEmpty)
        .map(_.toInt)
        .map(Card.apply)
        .toSeq
    } else {
      // special case, muck maybe?
      Nil
    }
  }

  val Suits = List("c", "d", "h", "s")
  val Ranks = List("2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A")

  implicit val encoder: Encoder[Card] = Encoder.forProduct2(
    "ordinal",
    "readable"
  )(card => (card.ordinal, card.readable))
}
