package models

import play.api.libs.json.{Json, Writes}

case class Card(ordinal: Int) {
  def readable: String = {
    val rank = Card.Ranks(ordinal / 4)
    val suit = Card.Suits(ordinal % 4)

    s"$rank$suit"
  }
}

object Card {
  val Suits = List("c", "d", "h", "s")
  val Ranks = List("2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A")
  implicit val writes: Writes[Card] = (card: Card) => {
    Json.obj(
      "value" -> card.readable
    )
  }
}