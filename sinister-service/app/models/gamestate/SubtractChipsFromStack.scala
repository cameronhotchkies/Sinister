package models.gamestate

import io.circe.{Encoder, Json}

case class SubtractChipsFromStack(seatIndex: Int, amount: Int)
    extends GameStateEvent
    with AppliesToPlayer {
  override def encoded: Json =
    SubtractChipsFromStack.encoder(this)
}

object SubtractChipsFromStack {
  implicit val encoder: Encoder[SubtractChipsFromStack] =
    Encoder.forProduct2(
      "subtractChips",
      "player"
    ) { scfs =>
      (scfs.seatIndex, scfs.amount)
    }
}
