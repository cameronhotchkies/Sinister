package models

import io.circe._
import io.circe.generic.semiauto._
import models.gamestate.GameStateEvent

case class GameStateMessage(
    id: Int,
    gameState: GameState,
    events: Seq[GameStateEvent]
)
object GameStateMessage {
  implicit val decoder: Decoder[GameStateMessage] = deriveDecoder
}
