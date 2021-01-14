package models

import play.api.Logger
import play.api.libs.functional.syntax.toFunctionalBuilderOps
import play.api.libs.json._

case class SeatedPlayer(
                         name: String,
                         level: Int,
                         dealtCards: Seq[Card]
                       ) {
  val logger: Logger = Logger("application")
  def merge(that: SeatedPlayer): SeatedPlayer = {

    val resolvedName = if (this.name == "RESERVED") {
      that.name
    } else {
      this.name
    }

    val resolvedLevel = if (this.level < 1) {
      that.level
    } else {
      this.level
    }

    val resolvedCards = if (dealtCards.isEmpty || dealtCards.equals(that.dealtCards)) {
      that.dealtCards
    } else if (that.dealtCards.isEmpty && dealtCards.nonEmpty) {
      this.dealtCards
    } else {
      logger.warn(s"($name) this: $dealtCards vs that: ${that.dealtCards}")
      ???
    }

    SeatedPlayer(resolvedName, resolvedLevel, resolvedCards)
  }
}
object SeatedPlayer {
  def deserializeCards(cardData: String): Seq[Card] = {
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

  implicit val reads: Reads[SeatedPlayer] = (
    (JsPath \ "n").read[String] and
      (JsPath \ "lvl").read[Int] and
      (JsPath \ "d").read[String].map(deserializeCards)
    )(SeatedPlayer.apply _)
  implicit val writes: Writes[SeatedPlayer] = Json.writes[SeatedPlayer]
  implicit val format: Format[SeatedPlayer] = Format(reads, writes)
}