package models.gamestate

import io.circe.parser
import org.scalatest.matchers._
import org.scalatest.wordspec._

class WinHandSpec extends AnyWordSpecLike with must.Matchers {
  "WinHand Player" must {

    "deserialize from JSON" in {
      val rawJson =
        """
          |   {
          |      "seatIndex" : 7,
          |      "amount" : 8643,
          |      "rawHandDetail" : "H.48;1;46;49;0.H.H",
          |      "handRank" : "Two Pair",
          |      "type" : 10
          |    }
          |    """.stripMargin

      val json = parser.decode[HandEvent](rawJson) match {
        case Right(winHand: WinHand) =>
          winHand.amount mustBe 8643
        case _ => fail()
      }
    }
  }
}
