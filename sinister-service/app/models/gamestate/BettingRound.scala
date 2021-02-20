package models.gamestate

import io.circe.syntax.EncoderOps
import io.circe.{Decoder, Encoder, HCursor, JsonObject}
import models.importer.GameStateEvent
import models.{Card, HandPlayer}

object BettingRound {
  implicit val encoder: Encoder.AsObject[BettingRound] =
    (bettingRound: BettingRound) =>
      JsonObject(
        "bettingRound" -> bettingRound.roundName.asJson,
        "communityCards" -> bettingRound.communityCards.asJson
      )

  implicit val decoder: Decoder[BettingRound] = (cursor: HCursor) => {

    for {
      parsedCards <- cursor.downField("communityCards").as[Seq[Card]]
      bettingRound <- cursor.downField("bettingRound").as[String]
    } yield {

      bettingRound match {
        case "preflop" => Preflop
        case "flop"    => Flop(parsedCards)
        case "turn"    => Turn(parsedCards)
        case "river"   => River(parsedCards)
        case _         => ???
      }
    }
  }
}

trait BettingRound extends HandEvent with GameStateEvent with GameNarrative {
  val communityCards: Seq[Card]

  val roundName: String

  protected def formattedOutput(): String = {
    s"=== ${roundName.capitalize} [${communityCards.map(_.readable).mkString(" ")}]} ==="
  }
}

case object Preflop extends BettingRound {
  override val communityCards: Seq[Card] = Nil
  override val roundName: String = "preflop"

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String = {
    "=== Preflop ==="
  }
}

case class Flop(override val communityCards: Seq[Card]) extends BettingRound {
  override val roundName: String = "flop"

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String =
    formattedOutput()
}

case class Turn(communityCards: Seq[Card]) extends BettingRound {
  override val roundName: String = "turn"

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String =
    formattedOutput()
}

case class River(communityCards: Seq[Card]) extends BettingRound {
  override val roundName: String = "river"

  override def narrative(implicit seats: Seq[Option[HandPlayer]]): String =
    formattedOutput()
}
