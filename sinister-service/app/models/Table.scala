package models

import io.circe.{Decoder, Encoder}
import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}

case class Table(
    tableName: String,
    id: Int,
    smallBlind: Int,
    bigBlind: Int,
    tableSize: Int
)

object Table {
  implicit val decoder:Decoder[Table] = deriveDecoder
  implicit val encoder: Encoder[Table] = deriveEncoder
}