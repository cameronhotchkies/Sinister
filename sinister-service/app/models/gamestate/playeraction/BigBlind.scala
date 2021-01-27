package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class BigBlind(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = BigBlind.encoder(this)
}

object BigBlind {
  implicit val encoder: Encoder.AsObject[BigBlind] = deriveEncoder
  implicit val decoder: Decoder[BigBlind] = deriveDecoder
}
