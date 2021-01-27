package models

import io.circe._
import io.circe.generic.semiauto._

case class HandState(
                      tableId: Int,
                      gameId: Int,
                      handPlayers: Seq[Option[HandPlayer]],
                      smallBlindIndex: Int,
                      bigBlindIndex: Int,
                      dealer: Dealer,
                      additionalData: GameStateAddition
) {}
object HandState {
  implicit val encoder: Encoder[HandState] = deriveEncoder
}
