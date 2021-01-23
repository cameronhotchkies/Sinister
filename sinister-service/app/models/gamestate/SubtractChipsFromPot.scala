package models.gamestate

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder, HCursor, Json}

case class SubtractChipsFromPot(seatIndex: Int, sidePotIndex: Int, amount: Int)
    extends GameStateEvent
    with AppliesToPlayer
    with GameNarrative {
  override def encoded: Json = SubtractChipsFromPot.encoder(this)
}

object SubtractChipsFromPot {
  implicit val encoder: Encoder[SubtractChipsFromPot] = deriveEncoder
  implicit val decoder: Decoder[SubtractChipsFromPot] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        sidePotIndex <- c.downField("side-pot").as[Int]
        amount <- c.downField("amount").as[Int]
      } yield SubtractChipsFromPot(seatIndex, sidePotIndex, amount)
    }
}
