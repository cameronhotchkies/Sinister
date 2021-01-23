package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class DoNotShowCards(seatIndex: Int) extends PlayerAction {
  override def encoded: Json = DoNotShowCards.encoder(this)
}

object DoNotShowCards {
  implicit val encoder: Encoder[DoNotShowCards] = Encoder.forProduct1("doNotShowCards")(DoNotShowCards.unapply)
}