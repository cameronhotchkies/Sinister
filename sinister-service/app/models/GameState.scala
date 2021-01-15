package models

import play.api.libs.functional.syntax.toFunctionalBuilderOps
import play.api.libs.json.{JsPath, Reads}


case class GameState(
                      tableId: Int,
                      gameId: Int,
                      seatedPlayers: Seq[SeatedPlayer],
                      smallBlindIndex: Int,
                      bigBlindIndex: Int,
                      dealer: Dealer
                    ) {}
object GameState {


  implicit val readsBuilder: Reads[GameState] = (
    (JsPath \ "ti").read[Int] and
      (JsPath \ "gi").read[Int] and
      (JsPath \ "s").read[Seq[SeatedPlayer]] and
      (JsPath \ "sb").read[Int] and
      (JsPath \ "bb").read[Int] and
      (JsPath \ "d").read[Dealer]
    )(GameState.apply _)
  //    implicit val format: Format[GameState] = Json.format[GameState]
}
