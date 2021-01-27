package models

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class Hand(summary: HandSummary, events: Seq[HandEvent], sources: Seq[String]) {}

object Hand {
  implicit val encoder: Encoder[Hand] = deriveEncoder
  implicit val decoder: Decoder[Hand] = deriveDecoder
}
