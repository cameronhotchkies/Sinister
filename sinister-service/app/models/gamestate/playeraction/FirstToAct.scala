package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class FirstToAct(seatIndex: Int) extends PlayerAction {
  override def encoded: Json =
    Json.obj(
      "firstToAct" -> Json.fromInt(seatIndex)
    )
}

object FirstToAct {
implicit val encoder: Encoder[FirstToAct] = Encoder.forProduct1(
  "firstToAct"
)(FirstToAct.unapply)
}