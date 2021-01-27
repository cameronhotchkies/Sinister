package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class DealerRake(amount: Int) extends GameStateEvent with HandEvent {}

object DealerRake {
  implicit val decoder: Decoder[DealerRake] = deriveDecoder
  implicit val encoder: Encoder.AsObject[DealerRake] = deriveEncoder
}
