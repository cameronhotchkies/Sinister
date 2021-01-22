package models

import io.circe.Json
import org.scalatest.matchers._
import org.scalatest.wordspec.AnyWordSpecLike

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

      val asJson = Card.encoder(card)

      val expected = Json.fromString("Ac")

      asJson mustBe expected
    }

    "deserialize a hand" in {
      val sampleHand = "42;36"

      val deserialized = Card.deserialize(sampleHand)

      deserialized mustBe List(
        Card(42),
        Card(36)
      )
    }

    "deserialize an hand" in {
      val sampleHand = ""

      val deserialized = Card.deserialize(sampleHand)

      deserialized mustBe Nil
    }

    "ignore an unknown hand" in {
      val sampleHand = "-1;-1"

      val deserialized = Card.deserialize(sampleHand)

      deserialized mustBe Nil
    }
  }
}
