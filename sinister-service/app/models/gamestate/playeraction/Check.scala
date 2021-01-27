package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class Check(seatIndex: Int) extends PlayerAction with HandEvent {
  def encoded: Json = Check.encoder(this)
}

object Check {
  implicit val encoder: Encoder.AsObject[Check] = deriveEncoder
  implicit val decoder: Decoder[Check] = deriveDecoder
}
