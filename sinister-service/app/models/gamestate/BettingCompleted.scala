package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.importer.GameStateEvent
import models.{Card, HandPlayer}

case class BettingCompleted() extends GameStateEvent
    with GameNarrative
    with HandEvent {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    "Betting complete"
  }

  override def toString: String = {
    s"Betting Complete"
  }
}

object BettingCompleted extends GameStateEvent with GameNarrative {
  implicit val decoder: Decoder[BettingCompleted] = deriveDecoder
  implicit val encoder: Encoder.AsObject[BettingCompleted] = deriveEncoder

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    "Next Round"
  }
}
