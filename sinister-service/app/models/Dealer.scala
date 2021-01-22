package models

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor}

case class Dealer(
    cards: Seq[Card]
) {
  def merge(that: Dealer): Dealer = {
    if (this.cards.length < that.cards.length) {
      that
    } else {
      this
    }
  }
}

object Dealer {
  implicit val decoder: Decoder[Dealer] = (c: HCursor) =>
    for {
      rawCards <- c.downField("c").as[String]
    } yield {
      Dealer(Card.deserialize(rawCards))
    }

  implicit val encoder: Encoder[Dealer] = deriveEncoder
}
