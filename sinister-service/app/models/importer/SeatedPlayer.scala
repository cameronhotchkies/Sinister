package models.importer

import io.circe.Decoder
import io.circe.generic.semiauto.deriveDecoder
import models.{Card, HandPlayer}

case class SeatedPlayer(n: String, lvl: Option[Int], d: String, c: Int) {
  implicit def toHandPlayer: HandPlayer = {
    HandPlayer(n, lvl, cards, c)
  }

  val cards: Seq[Card] = Card.deserialize(d)
}

object SeatedPlayer {
  implicit val decoder: Decoder[SeatedPlayer] = deriveDecoder
}
