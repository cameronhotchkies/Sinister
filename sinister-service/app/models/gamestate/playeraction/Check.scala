package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class Check(seatIndex: Int) extends PlayerAction with HandEvent {
  def encoded: Json = Check.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("a whisper of a wisp")(_.name)
    s"$player checks"
  }
}

object Check {
  implicit val encoder: Encoder.AsObject[Check] = deriveEncoder
  implicit val decoder: Decoder[Check] = deriveDecoder
}
