package models.importer

import java.io.File

case class MessageWithSource(gameStateMessage: GameStateMessage, source: File)

object MessageWithSource {
  implicit def extractMessage(m: MessageWithSource): GameStateMessage = {
    m.gameStateMessage
  }
}
