package models.importer

import io.circe.generic.semiauto.deriveDecoder
import io.circe.{Decoder, Json}

case class TablesList(t: String, id: Int, srcMsgId: Int, tables: Seq[Json])

object TablesList {
  implicit val decoder: Decoder[TablesList] = deriveDecoder
}
