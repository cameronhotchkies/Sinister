package models.importer

import io.circe._
import io.circe.generic.semiauto._

case class GameStateMessage(
    id: Int,
    ts: Long,
    gameState: GameState,
    events: Seq[GameStateEvent]
)
object GameStateMessage {
  implicit val decoder: Decoder[GameStateMessage] = deriveDecoder
}
