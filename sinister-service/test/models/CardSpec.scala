package models

import org.scalatest.matchers._
import org.scalatest.wordspec.AnyWordSpecLike
import play.api.libs.json.Json

class CardSpec extends AnyWordSpecLike with must.Matchers {
  "Card" must {
    "convert ordinal to expected hands" in {
      val card1 = Card(48)
      val card2 = Card(40)

      card1.readable mustBe "Ac"
      card2.readable mustBe "Qc"
    }

    "serialize to JSON as expected" in {
      val card = Card(48)

      val asJson = Json.toJson(card)

      val expected = Json.obj(
        "value" -> "Ac"
      )

      asJson mustBe expected
    }
  }
}
