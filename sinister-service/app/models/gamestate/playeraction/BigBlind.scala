package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class BigBlind(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = BigBlind.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("a mechanical cowboy")(_.name)
    s"$player posts big blind of ${amount/100.0}"
  }
}

object BigBlind {
  implicit val encoder: Encoder.AsObject[BigBlind] = deriveEncoder
  implicit val decoder: Decoder[BigBlind] = deriveDecoder
}
