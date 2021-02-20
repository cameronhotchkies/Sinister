package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.gamestate.HandEvent

case class DoNotShowCards(seatIndex: Int) extends PlayerAction with HandEvent {

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("the invisible person")(_.name)
    s"$player does not show cards"
  }
}

object DoNotShowCards {
  implicit val encoder: Encoder.AsObject[DoNotShowCards] = deriveEncoder
  implicit val decoder: Decoder[DoNotShowCards] = deriveDecoder
}
