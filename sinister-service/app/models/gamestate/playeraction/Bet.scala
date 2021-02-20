package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class Bet(seatIndex: Int, amount: Int)
    extends PlayerAction
    with HandEvent {
  def encoded: Json = Bet.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("a painted illustration of a dog")(_.name)
    f"$player bets ${amount/100.0}"
  }
}

object Bet {
  implicit val encoder: Encoder.AsObject[Bet] = deriveEncoder
  implicit val decoder: Decoder[Bet] = deriveDecoder
}
