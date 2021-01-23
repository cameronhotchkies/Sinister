package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class Check(seatIndex: Int) extends PlayerAction {
  def encoded: Json = Check.encoder(this)
}

object Check {
  implicit val encoder: Encoder[Check] =
    Encoder.forProduct1("check")(Check.unapply)
}
