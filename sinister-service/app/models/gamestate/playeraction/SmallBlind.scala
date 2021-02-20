package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class SmallBlind(seatIndex: Int, smallBlind: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = SmallBlind.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("an organic cowperson")(_.name)
    s"$player posts small blind of ${smallBlind/100.0}"
  }
}

object SmallBlind {
  implicit val encoder: Encoder.AsObject[SmallBlind] = deriveEncoder
  implicit val decoder: Decoder[SmallBlind] = deriveDecoder
}
