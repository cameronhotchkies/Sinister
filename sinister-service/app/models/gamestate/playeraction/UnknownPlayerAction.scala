package models.gamestate.playeraction

import io.circe.generic.semiauto.deriveDecoder
import io.circe.{Decoder, Encoder, Json}
import models.gamestate.HandEvent

case class UnknownPlayerAction(subAction: Int, rawJson: Json)
    extends PlayerAction
    with HandEvent {
  override val seatIndex: Int = -1
  val encoded: Json = UnknownPlayerAction.encoder(this)
}

object UnknownPlayerAction {
  implicit val encoder: Encoder.AsObject[UnknownPlayerAction] =
    Encoder.forProduct3(
      "undefinedPlayerAction",
      "subAction",
      "source"
    ) { source =>
      {
        (true, source.subAction, source.rawJson)
      }
    }

  implicit val decoder: Decoder[UnknownPlayerAction] = deriveDecoder
}
