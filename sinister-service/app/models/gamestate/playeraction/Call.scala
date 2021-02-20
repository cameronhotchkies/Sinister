package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class Call(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Call.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("two small children in a trench coat")(_.name)
    s"$player calls ${amount/100.0}"
  }
}

object Call {
  implicit val encoder: Encoder.AsObject[Call] = deriveEncoder
  implicit val decoder: Decoder[Call] = deriveDecoder
}
