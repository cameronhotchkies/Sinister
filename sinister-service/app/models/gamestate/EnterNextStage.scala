package models.gamestate

import io.circe.Json

case object EnterNextStage extends GameStateEvent with GameNarrative {
  def apply(): Any = ???

  override def encoded: Json = {
    Json.obj("nextPhase" -> Json.fromBoolean(true))
  }
}
