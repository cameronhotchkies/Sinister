package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.gamestate.HandEvent

case class MuckCards(seatIndex: Int) extends PlayerAction with HandEvent {

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("a sludge monster from the depths below")(_.name)

    s"$player mucks"
  }
}

object MuckCards {
  implicit val encoder: Encoder.AsObject[MuckCards] = deriveEncoder
  implicit val decoder: Decoder[MuckCards] = deriveDecoder
}
