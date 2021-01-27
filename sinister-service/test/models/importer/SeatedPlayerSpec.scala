package models.importer

import io.circe.parser
import org.scalatest.matchers._
import org.scalatest.wordspec._
import scaffolding._

class SeatedPlayerSpec extends AnyWordSpecLike with must.Matchers {
  "Seated Player" must {

    "deserialize from JSON" in {
      val rawPlayerData =
        """
          |{
          |  "n": "testPlayer",
          |  "lvl": 67,
          |  "d": "14;15"
          |}
          |""".stripMargin

      val playerDataJson = parser
        .parse(rawPlayerData)

      playerDataJson.map(json => {
        val seatedPlayer = SeatedPlayer.decoder.decodeJson(json)

        seatedPlayer.fold(
          { _ => fail() },
          { player =>
            player.cards.map(_.readable) mustBe List("5h", "5s")
            player.n mustBe "testPlayer"
            player.lvl must be(defined)
            player.lvl.get mustBe 67
          }
        )
      })
    }
  }
}
