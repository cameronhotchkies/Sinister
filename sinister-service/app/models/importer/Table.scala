package models.importer

import io.circe.Decoder
import io.circe.generic.semiauto.deriveDecoder
import models.{Table => ModelTable}

case class Table(n: String, i: Int, s: Int, bb: Int, mp: Int) {
  implicit def toTable: ModelTable = {
    ModelTable(n, i, s, bb, mp)
  }
}
object Table {
  implicit val decoder: Decoder[Table] = deriveDecoder
}