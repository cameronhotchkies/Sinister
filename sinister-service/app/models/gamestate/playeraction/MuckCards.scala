package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class MuckCards(seatIndex: Int) extends PlayerAction with HandEvent {}

object MuckCards {
  implicit val encoder: Encoder.AsObject[MuckCards] = deriveEncoder
  implicit val decoder: Decoder[MuckCards] = deriveDecoder
}
