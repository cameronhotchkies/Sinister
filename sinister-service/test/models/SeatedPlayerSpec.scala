package models

import org.scalatest.matchers._
import org.scalatest.matchers.must.Matchers._
import org.scalatest.wordspec.AnyWordSpecLike
import play.api.libs.json.Json

class SeatedPlayerSpec extends AnyWordSpecLike with must.Matchers {
  "Seated Player" must {

    "deserialize a hand" in {
      val sampleHand = "42;36"

      val deserialized = SeatedPlayer.deserializeCards(sampleHand)

      deserialized mustBe List(
        Card(42),
        Card(36)
      )
    }

    "deserialize an hand" in {
      val sampleHand = ""

      val deserialized = SeatedPlayer.deserializeCards(sampleHand)

      deserialized mustBe Nil
    }

    "ignore an unknown hand" in {
      val sampleHand = "-1;-1"

      val deserialized = SeatedPlayer.deserializeCards(sampleHand)

      deserialized mustBe Nil
    }

    "merge as expected" in {
      val playerName = "test39"
      val playerLevel = 40
      val player1a =
        SeatedPlayer(name = playerName, level = playerLevel, dealtCards = Nil)
      val player1b = SeatedPlayer(
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
      val playerLevel = 57
      val player1a =
        SeatedPlayer(name = "RESERVED", level = 0, dealtCards = Nil)
      val player1b = SeatedPlayer(
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
        SeatedPlayer(name = playerName, level = playerLevel, dealtCards = List(
          Card(15),Card(16)
        ))
      val player1b = SeatedPlayer(
        name = playerName,
        level = playerLevel,
        dealtCards = Nil
      )

      val merged = player1a.merge(player1b)
      merged.name mustBe playerName
      merged.level mustBe playerLevel
      merged.dealtCards.map(_.readable) mustBe List("5s", "6c")
    }
  }
}
