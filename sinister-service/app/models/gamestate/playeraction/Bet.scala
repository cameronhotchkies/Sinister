package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class Bet(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Bet.encoder(this)
}

object Bet {
  implicit val encoder: Encoder.AsObject[Bet] = deriveEncoder
  implicit val decoder: Decoder[Bet] = deriveDecoder
}
