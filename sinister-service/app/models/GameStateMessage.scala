package models

import play.api.libs.json.{Json, Reads}

case class GameStateMessage(
    id: Int,
    gameState: GameState,
    events: Seq[GameStateEvent]
)
object GameStateMessage {
  implicit val reads: Reads[GameStateMessage] = Json.reads[GameStateMessage]
}
