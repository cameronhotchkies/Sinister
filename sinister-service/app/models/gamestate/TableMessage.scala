package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class TableMessage(message: String, seatIndex: Int)
  extends GameStateEvent
    with GameNarrative
    with HandEvent {}

object TableMessage {
  implicit val encoder: Encoder.AsObject[TableMessage] = deriveEncoder
  implicit val decoder: Decoder[TableMessage] = deriveDecoder
}
