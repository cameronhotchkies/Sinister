package models

import play.api.libs.functional.syntax.toFunctionalBuilderOps
import play.api.libs.json._

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
  implicit val reads: Reads[Dealer] = (JsPath \ "c").read[String].map(Card.deserialize).map(Dealer.apply)
}
