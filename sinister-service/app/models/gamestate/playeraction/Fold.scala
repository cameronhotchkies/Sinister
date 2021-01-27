package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class Fold(seatIndex: Int) extends PlayerAction with HandEvent {
  def encoded: Json = Fold.encoder(this)
}

object Fold {
  implicit val encoder: Encoder.AsObject[Fold] = deriveEncoder
  implicit val decoder: Decoder[Fold] = deriveDecoder
}
