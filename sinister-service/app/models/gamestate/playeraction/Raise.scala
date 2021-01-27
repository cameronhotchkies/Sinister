package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class Raise(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Raise.encoder(this)
}

object Raise {
  implicit val encoder: Encoder.AsObject[Raise] = deriveEncoder
  implicit val decoder: Decoder[Raise] = deriveDecoder
}
