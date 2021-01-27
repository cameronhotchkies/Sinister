package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class Call(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Call.encoder(this)
}

object Call {
  implicit val encoder: Encoder.AsObject[Call] = deriveEncoder
  implicit val decoder: Decoder[Call] = deriveDecoder
}
