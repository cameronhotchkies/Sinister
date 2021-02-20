package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class Raise(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Raise.encoder(this)


  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("A Matt Damon impersonator")(_.name)

     s"$player raises ${amount/100.0}"
  }
}

object Raise {
  implicit val encoder: Encoder.AsObject[Raise] = deriveEncoder
  implicit val decoder: Decoder[Raise] = deriveDecoder
}
