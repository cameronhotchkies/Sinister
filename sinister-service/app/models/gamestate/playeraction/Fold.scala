package models.gamestate.playeraction

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, Json}
import models.HandPlayer
import models.gamestate.HandEvent

case class Fold(seatIndex: Int) extends PlayerAction with HandEvent {
  def encoded: Json = Fold.encoder(this)

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    val player = seats(seatIndex).fold("an origami expert")(_.name)
    s"$player folds"
  }
}

object Fold {
  implicit val encoder: Encoder.AsObject[Fold] = deriveEncoder
  implicit val decoder: Decoder[Fold] = deriveDecoder
}
