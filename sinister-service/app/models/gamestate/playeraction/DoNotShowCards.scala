package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class DoNotShowCards(seatIndex: Int) extends PlayerAction with HandEvent {}

object DoNotShowCards {
  implicit val encoder: Encoder.AsObject[DoNotShowCards] = deriveEncoder
  implicit val decoder: Decoder[DoNotShowCards] = deriveDecoder
}
