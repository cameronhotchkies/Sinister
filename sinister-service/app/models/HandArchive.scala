package models

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class HandArchive(summary: Hand, events: Seq[HandEvent], sources: Seq[String]) {}

object HandArchive {
  implicit val encoder: Encoder[HandArchive] = deriveEncoder
  implicit val decoder: Decoder[HandArchive] = deriveDecoder
}
