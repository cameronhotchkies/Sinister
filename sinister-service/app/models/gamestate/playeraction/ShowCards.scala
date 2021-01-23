package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class ShowCards(seatIndex: Int) extends PlayerAction {
  override def encoded: Json = ShowCards.encoder(this)
}

object ShowCards {
  implicit val encoder: Encoder[ShowCards] = Encoder.forProduct1("showCards")(ShowCards.unapply)
}