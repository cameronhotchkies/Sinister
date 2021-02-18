package models

import io.circe.syntax.EncoderOps
import io.circe.{Encoder, Json}
import models.Hand.logger
import models.gamestate._
import models.gamestate.playeraction.Fold

case class HeroHand(hero: String, hand: Hand) {
  private val position = hand.positionForPlayer(hero)

  lazy val cards =
    hand.seatedPlayers(position).map(_.dealtCards.map(_.readable))

  def bigBlindsWon(): Option[BigDecimal] = {

    val chipMovementEvents = hand.events.filter {
      case subtractChipsFromStack: SubtractChipsFromStack =>
        subtractChipsFromStack.seatIndex == position
      case subtractChipsFromPot: SubtractChipsFromPot =>
        subtractChipsFromPot.seatIndex == position
      case _ => false
    }

    val chipDelta = chipMovementEvents.foldLeft(BigDecimal(0)) { (acc, event) =>
      event match {
        case SubtractChipsFromStack(_, chips)  => acc - chips
        case SubtractChipsFromPot(_, _, chips) => acc + chips
      }
    }

    hand.table.map { tbl =>
      chipDelta / tbl.bigBlind
    }
  }

  def wentToShowdown(): Option[Boolean] = {
    if (hand.stages.contains(1)) {

      val collected = hand.events.collectFirst {
        case EnterNextStage(_)              => true
        case Fold(seat) if seat == position => false
      }

      collected.flatMap { flopEntered =>
        if (flopEntered) {
          val seatsInShowdown = hand.playersInvolvedInShowdown

          Option(seatsInShowdown.contains(position))
        } else {
          None
        }
      }
    } else {
      logger.info("[.] No Flop")
      None
    }
  }

  def postFlopEvents: Seq[HandEvent] = {
    hand.events.dropWhile(_.isInstanceOf[EnterNextStage] == false)
  }

  def wonWhenSawFlop(): Option[Boolean] = {
    val pfe = postFlopEvents
    if (pfe.nonEmpty) {

      val winEvents = postFlopEvents
        .filter(_.isInstanceOf[WinHand])
        .filter(_.asInstanceOf[WinHand].seatIndex == position)
      Option(winEvents.nonEmpty)
    } else {
      None
    }
  }

  def w$sd(): Option[Boolean] = {
    wentToShowdown().flatMap { relevant =>
      {
        if (relevant) {
          Option(
            hand.events
              .collectFirst {
                case WinHand(seat, _, _) if seat == position => true
              }
              .getOrElse(false)
          )
        } else {
          None
        }
      }
    }
  }
}

object HeroHand {
  implicit val encoder: Encoder[HeroHand] = (heroHand: HeroHand) => {
    Hand
      .encoder(heroHand.hand)
      .deepMerge(
        Json.obj(
          "wtsd" -> heroHand.wentToShowdown().asJson,
          "wwsf" -> heroHand.wonWhenSawFlop().asJson,
          "w$sd" -> heroHand.w$sd().asJson,
          "bbWon" -> heroHand.bigBlindsWon().asJson
        )
      )
  }
}
