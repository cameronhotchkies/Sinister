package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder}
import models.HandPlayer
import models.gamestate.HandEvent

case class ShowCards(seatIndex: Int) extends PlayerAction with HandEvent {

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {

    seats(seatIndex).fold("someone, somewhere shows off the goods. Not here."){ player =>
      s"${player.name} shows ${player.dealtCards.map(_.readable).mkString(" ")}"
    }
  }
}

object ShowCards {
  implicit val encoder: Encoder.AsObject[ShowCards] = deriveEncoder
  implicit val decoder: Decoder[ShowCards] = deriveDecoder
}
