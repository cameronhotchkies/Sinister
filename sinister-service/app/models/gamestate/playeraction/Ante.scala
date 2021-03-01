package models.gamestate.playeraction

import io.circe.{Decoder, Encoder}
import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import models.HandPlayer
import models.gamestate.HandEvent

case class Ante(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String =
    "ante!!"
}
object Ante {
  implicit val encoder: Encoder.AsObject[Ante] = deriveEncoder
  implicit val decoder: Decoder[Ante] = deriveDecoder
}
