package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent

case class EnterNextStage(stage: Int = -1)
    extends GameStateEvent
    with HandEvent {}

object EnterNextStage extends GameStateEvent with GameNarrative {
  implicit val decoder: Decoder[EnterNextStage] = deriveDecoder
  implicit val encoder: Encoder.AsObject[EnterNextStage] = deriveEncoder
}
