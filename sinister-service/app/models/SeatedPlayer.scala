package models

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor}
import play.api.Logger

case class SeatedPlayer(
    name: String,
    level: Option[Int],
    dealtCards: Seq[Card]
) {
  val logger: Logger = Logger("application")
  def merge(that: SeatedPlayer): SeatedPlayer = {

    val resolvedName = if (this.name == "RESERVED") {
      that.name
    } else {
      this.name
    }

    val resolvedLevel = if (this.level.getOrElse(0) < 1) {
      that.level
    } else {
      this.level
    }

    // Remove any facedown cards
    val thisDealt = this.dealtCards.filter(!_.faceDown)
    val thatDealt = that.dealtCards.filter(!_.faceDown)

    val resolvedCards = (thisDealt, thatDealt) match {
      case (a, b) if a == b => this.dealtCards
      case (_, Nil)           => this.dealtCards
      case (Nil, _)           => that.dealtCards
      case default =>
        logger.warn(s"($name) this: $dealtCards vs that: ${that.dealtCards}")
        ???
    }

    SeatedPlayer(resolvedName, resolvedLevel, resolvedCards)
  }
}
object SeatedPlayer {

  implicit val decoder: Decoder[SeatedPlayer] = (c: HCursor) =>
    for {
      foo <- c.downField("n").as[String]
      bar <- c.downField("lvl").as[Option[Int]]
      rawCard <- c.downField("d").as[String]
    } yield {
      new SeatedPlayer(foo, bar, Card.deserialize(rawCard))
    }

  implicit  val encoder: Encoder[SeatedPlayer] = deriveEncoder

}
