package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class ShowCards(seatIndex: Int) extends PlayerAction with HandEvent {}

object ShowCards {
  implicit val encoder: Encoder.AsObject[ShowCards] = deriveEncoder
  implicit val decoder: Decoder[ShowCards] = deriveDecoder
}
