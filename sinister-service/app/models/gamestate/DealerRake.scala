package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.importer.GameStateEvent

case class DealerRake(amount: Int) extends GameStateEvent with HandEvent with GameNarrative {
  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    f"Rake applied: ${amount/100.0}%.2f chips"
  }
}

object DealerRake {
  implicit val decoder: Decoder[DealerRake] = deriveDecoder
  implicit val encoder: Encoder.AsObject[DealerRake] = deriveEncoder
}
