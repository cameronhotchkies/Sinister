package models.gamestate.playeraction

import io.circe.{Encoder, Json}

case class UnknownPlayerAction(subAction: Int, rawJson: Json)
    extends PlayerAction {
  override val seatIndex: Int = -1
  val encoded: Json = UnknownPlayerAction.encoder(this)
}

object UnknownPlayerAction {
  implicit val encoder: Encoder[UnknownPlayerAction] = Encoder.forProduct3(
    "undefinedPlayerAction",
    "subAction",
    "source"
  ) { source => {
    (true, source.subAction, source.rawJson)
  }}
}
