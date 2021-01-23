package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class MuckCards(seatIndex: Int) extends PlayerAction {
  override def encoded: Json = MuckCards.encoder(this)
}

object MuckCards {
  implicit val encoder: Encoder[MuckCards] = Encoder.forProduct1("muckCards")(MuckCards.unapply)
}
