package models

import io.circe.Encoder
import io.circe.generic.semiauto.deriveEncoder
import models.gamestate.GameStateEvent

case class Hand(summary: HandSummary, events: Seq[GameStateEvent]) {}

object Hand {
  implicit val encoder: Encoder[Hand] = deriveEncoder
}
