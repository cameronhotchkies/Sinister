package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.importer.GameStateEvent

case class TableMessage(message: String, seatIndex: Int)
  extends GameStateEvent
    with GameNarrative
    with HandEvent {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    s"TBL MSG: $message"
  }
}

object TableMessage {
  implicit val encoder: Encoder.AsObject[TableMessage] = deriveEncoder
  implicit val decoder: Decoder[TableMessage] = deriveDecoder
}
