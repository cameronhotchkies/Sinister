package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class PlayerFold(seatIndex: Int) extends PlayerAction {
  def encoded: Json = PlayerFold.encoder(this)
}

object PlayerFold {
  implicit val encoder: Encoder[PlayerFold] = Encoder.forProduct1("playerFold")(PlayerFold.unapply)
}
