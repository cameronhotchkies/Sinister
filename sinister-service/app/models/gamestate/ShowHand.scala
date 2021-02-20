package models.gamestate

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.importer.GameStateEvent

case class ShowHand(seatIndex: Int)
    extends GameStateEvent
    with GameNarrative
    with AppliesToPlayer
    with HandEvent {

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    seats(seatIndex)
      .map { player =>
        s"${player.name} shows ${player.dealtCards.map(_.readable).mkString(" ")}"
      }
      .getOrElse("A ghost shows it's ethereal hand [ERR]")

  }
}

object ShowHand {
  implicit val encoder: Encoder.AsObject[ShowHand] = deriveEncoder
  implicit val decoder: Decoder[ShowHand] = deriveDecoder
}
