package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

object TableMessage {
  implicit val encoder: Encoder[TableMessage] = deriveEncoder
  implicit val decoder: Decoder[TableMessage] =
    (c: HCursor) => {
      for {
        message <- c.downField("table-msg").as[String]
        messageTarget <- c.downField("seat-idx").as[Int]
      } yield TableMessage(message, messageTarget)
    }
}

case class TableMessage(message: String, seatIndex: Int)
    extends GameStateEvent
    with GameNarrative {
  override def encoded: Json = TableMessage.encoder(this)
}
