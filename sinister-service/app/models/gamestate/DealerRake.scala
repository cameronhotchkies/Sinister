package models.gamestate

import io.circe.generic.semiauto.deriveDecoder
import io.circe.{Decoder, Encoder, Json}

object DealerRake {
  implicit val decoder: Decoder[DealerRake] = deriveDecoder
  implicit val encoder: Encoder[DealerRake] =
    Encoder.forProduct1("rake")(DealerRake.unapply)
}

case class DealerRake(amount: Int) extends GameStateEvent {
  override def encoded: Json = DealerRake.encoder(this)
}
