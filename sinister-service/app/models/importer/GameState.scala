package models.importer

import io.circe.Decoder
import models.{Dealer, GameStateAddition, HandState}

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

  implicit def toHandState(gameState: GameState): HandState = {
    HandState(
      gameState.tableId,
      gameState.gameId,
      gameState.seatedPlayers.map(_.map(_.toHandPlayer)),
      gameState.smallBlindIndex,
      gameState.bigBlindIndex,
      gameState.dealer,
      gameState.additionalData
    )
  }

}
