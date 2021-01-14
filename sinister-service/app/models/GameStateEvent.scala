package models

import play.api.libs.json.{Json, Reads}

case class GameStateEvent(`type`: Int)

object GameStateEvent {
  implicit val reads: Reads[GameStateEvent] = Json.reads[GameStateEvent]
}
