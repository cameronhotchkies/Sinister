package models

import io.circe.parser
import org.scalatest.matchers._
import org.scalatest.wordspec._
import scaffolding._

class HandPlayerSpec extends AnyWordSpecLike with must.Matchers {
  "Seated Player" must {
    "merge as expected" in {
      val playerName = "test39"
      val playerLevel = Option(40)
      val player1a =
        HandPlayer(name = playerName, level = playerLevel, dealtCards = Nil)
      val player1b = HandPlayer(
        name = playerName,
        level = playerLevel,
        dealtCards = List(Card(33), Card(34))
      )

      val merged = player1a.merge(player1b)
      merged.name mustBe playerName
      merged.level mustBe playerLevel
      merged.dealtCards.map(_.readable) mustBe List("Td", "Th")
    }

    "merge from reserved seat" in {
      val playerName = "test39"
      val playerLevel = Option(57)
      val player1a =
        HandPlayer(name = "RESERVED", level = None, dealtCards = Nil)
      val player1b = HandPlayer(
        name = playerName,
        level = playerLevel,
        dealtCards = List(Card(33), Card(34))
      )

      val merged = player1a.merge(player1b)
      merged.name mustBe playerName
      merged.level mustBe playerLevel
      merged.dealtCards.map(_.readable) mustBe List("Td", "Th")
    }

    "merge from discarded hand" in {
      val playerName = "test39"
      val playerLevel = 74
      val player1a =
        HandPlayer(
          name = playerName,
          level = Option(playerLevel),
          dealtCards = List(
            Card(15),
            Card(16)
          )
        )
      val player1b = HandPlayer(
        name = playerName,
        level = Option(playerLevel),
        dealtCards = Nil
      )

      val merged = player1a.merge(player1b)
      merged.name mustBe playerName

      merged.level mustNot be(empty)
      merged.level.get mustBe playerLevel
      merged.dealtCards.map(_.readable) mustBe List("5s", "6c")
    }
  }
}
