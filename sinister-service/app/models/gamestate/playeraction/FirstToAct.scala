package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.gamestate.HandEvent

case class FirstToAct(seatIndex: Int) extends PlayerAction with HandEvent {}

object FirstToAct {
  implicit val encoder: Encoder.AsObject[FirstToAct] = deriveEncoder
  implicit val decoder: Decoder[FirstToAct] = deriveDecoder
}
