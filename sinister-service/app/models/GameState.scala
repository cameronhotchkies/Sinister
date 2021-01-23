package models

import io.circe._
import io.circe.generic.semiauto._

case class GameState(
    tableId: Int,
    gameId: Int,
    seatedPlayers: Seq[Option[SeatedPlayer]],
    smallBlindIndex: Int,
    bigBlindIndex: Int,
    dealer: Dealer,
    additionalData: GameStateAddition
) {}
object GameState {

  implicit val decoder: Decoder[GameState] = Decoder.forProduct7(
    "ti",
    "gi",
    "s",
    "sb",
    "bb",
    "d",
    "m"
  )(GameState.apply)

  implicit val encoder: Encoder[GameState] = deriveEncoder
}
