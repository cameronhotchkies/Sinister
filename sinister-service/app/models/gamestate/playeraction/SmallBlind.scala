package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class SmallBlind(seatIndex: Int, smallBlind: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = SmallBlind.encoder(this)
}

object SmallBlind {
  implicit val encoder: Encoder.AsObject[SmallBlind] = deriveEncoder
  implicit val decoder: Decoder[SmallBlind] = deriveDecoder
}
