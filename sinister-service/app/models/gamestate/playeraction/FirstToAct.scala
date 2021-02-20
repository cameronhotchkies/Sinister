package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.gamestate.HandEvent

case class FirstToAct(seatIndex: Int) extends PlayerAction with HandEvent {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player =
      seats(seatIndex).fold("a fold in time and space itself")(_.name)

    s"Action to $player"
  }
}

object FirstToAct {
  implicit val encoder: Encoder.AsObject[FirstToAct] = deriveEncoder
  implicit val decoder: Decoder[FirstToAct] = deriveDecoder
}
