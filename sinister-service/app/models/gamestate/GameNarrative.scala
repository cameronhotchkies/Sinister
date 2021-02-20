package models.gamestate

import models.HandPlayer

trait GameNarrative {
  def narrative(implicit seats: Seq[Option[HandPlayer]]):String
}
