package models

import org.scalatest.matchers._
import org.scalatest.wordspec._
import play.api.libs.json.Json

class SeatedPlayerSpec extends AnyWordSpecLike with must.Matchers {
  "Seated Player" must {
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
        SeatedPlayer(
          name = playerName,
          level = playerLevel,
          dealtCards = List(
            Card(15),
            Card(16)
          )
        )
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

  "deserialize from JSON" in {
    val rawPlayerData =
      """
        |{
        |  "n": "testPlayer",
        |  "lvl": 67,
        |  "d": "14;15"
        |}
        |""".stripMargin

    val playerData_ = Json
      .parse(rawPlayerData)
      .validate[SeatedPlayer]

    val o = playerData_.asOpt
    o mustNot be(None)

    val player = playerData_.get
    player.dealtCards.map(_.readable) mustBe List("5h", "5s")
    player.name mustBe "testPlayer"
    player.level mustBe 67
  }

}
