package models

import org.scalatest.matchers._
import org.scalatest.wordspec.AnyWordSpecLike
import play.api.libs.json.Json

class DealerSpec extends AnyWordSpecLike with must.Matchers {
  "Dealer" must {
    "merge with an updated hand" in {
      val preflop = Dealer(Nil)
      val postflop = Dealer(List(Card(11), Card(12), Card(13)))

      val merged = preflop.merge(postflop)

      merged.cards.length mustBe 3
    }

    "merge with after a hand" in {
      val flop = Dealer(List(Card(11), Card(12), Card(13)))
      val afterShowdown = Dealer(Nil)

      val merged = flop.merge(afterShowdown)

      merged.cards.length mustBe 3
    }

    "deserialize from json" in {
      val raw =
        """{
          |  "c": "8;42"
          |}
          |""".stripMargin

      val parsed = Json.parse(raw).validate[Dealer]

      parsed.get.cards.map(_.readable) mustBe List("4c", "Qh")
    }
  }
}
