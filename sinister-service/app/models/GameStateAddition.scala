package models

import io.circe.generic.semiauto.deriveEncoder
import io.circe.{Decoder, Encoder}

case class GameStateAddition(stage: Int)

object GameStateAddition {
  implicit val decoder: Decoder[GameStateAddition] =
    Decoder.forProduct1("r")(GameStateAddition.apply)

  implicit val encoder: Encoder[GameStateAddition] = deriveEncoder

  val Clear = 0
  val PreFlop = 1
  val Flop = 2
  val Turn = 3
  val River = 4
  val DetermineWinner = 5
  val GameOver = 6
}
