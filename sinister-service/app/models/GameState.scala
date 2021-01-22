package models

import io.circe._
import io.circe.generic.semiauto._

case class GameState(
    tableId: Int,
    gameId: Int,
    seatedPlayers: Seq[Option[SeatedPlayer]],
    smallBlindIndex: Int,
    bigBlindIndex: Int,
    dealer: Dealer
) {}
object GameState {

  implicit val decoder: Decoder[GameState] = Decoder.forProduct6(
    "ti",
    "gi",
    "s",
    "sb",
    "bb",
    "d"
  )(GameState.apply)

  implicit val encoder: Encoder[GameState] = deriveEncoder
}
