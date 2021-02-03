package models.opponent

import io.circe.Encoder
import io.circe.generic.semiauto.deriveEncoder
import models.Hand
import models.gamestate.{AppliesToPlayer, HandEvent}
import models.gamestate.playeraction.{Bet, Call, Raise}

import scala.math.BigDecimal.RoundingMode

case class Profile(playStyle: PlayStyle, winRate: BigDecimal) {}

object Profile {
  private val UnknownProfile = Profile(PlayStyle(0,0,0,0), 0)
  implicit val encoder: Encoder[Profile] = deriveEncoder

  def apply(hands: Seq[Hand], player: String): Profile = {
    if (hands.nonEmpty) {
      val playStyle = generatePlayStyle(hands, player)
      val winRate = bbPer100(hands, player)

      Profile(playStyle, winRate)
    } else { UnknownProfile }
  }

  def bbPer100(hands: Seq[Hand], player: String): BigDecimal = {
    val handCount = hands.length

    if (handCount > 0) {
      (hands.flatMap(_.bigBlindsWonByPlayer(player)).sum / handCount * 100)
        .setScale(2, RoundingMode.DOWN)
        .rounded
    } else { 0 }
  }

  def generatePlayStyle(hands: Seq[Hand], player: String): PlayStyle = {
    val voluntaryPlayed = voluntarilyPlayedHands(hands, player)
    val playedCount = hands.length

    val aggressivelyPlayed = voluntaryPlayed.filter(hand => {
      val playerPosition = hand.positionForPlayer(player)
      val aggressiveAction = hand.preflopEvents.exists {
        case r: Raise => r.seatIndex == playerPosition
        case _        => false
      }

      aggressiveAction
    })

    val aggressionFactor = calculateAggressionFactor(player, hands)

    val vpipHands = voluntaryPlayed.length
    val pfrHands = aggressivelyPlayed.length

    val vpip = ((vpipHands.toDouble / playedCount) * 1000).round / 10f
    val pfr = ((pfrHands.toDouble / playedCount) * 1000).round / 10f

    val aggressionRatio = ((pfr / vpip) * 1000).round / 100f

    PlayStyle(vpip, pfr, aggressionRatio, aggressionFactor)
  }

  case class BettingEvents(
      aggressor: Seq[HandEvent],
      passive: Seq[HandEvent]
  ) {
    def +(that: BettingEvents): BettingEvents = {
      BettingEvents(
        this.aggressor ++ that.aggressor,
        this.passive ++ that.passive
      )
    }
  }

  def calculateAggressionFactor(player: String, hands: Seq[Hand]): Double = {
    val playerWagers = hands
      .map(hand => {
        val playerPosition = hand.positionForPlayer(player)
        val playerEvents = hand.events.filter {
          case atp: AppliesToPlayer => atp.seatIndex == playerPosition
          case _                    => false
        }

        val bettingEvents = playerEvents
          .filter {
            case _: Raise => true
            case _: Bet   => true
            case _: Call  => true
            case _        => false
          }
          // Using not Call as it's shorter
          .partition(!_.isInstanceOf[Call])

        bettingEvents
      })
      .map(BettingEvents.tupled)
      .fold(BettingEvents(Nil, Nil))(_ + _)

    val aggressionFactor =
      ((playerWagers.aggressor.length.toDouble / playerWagers.passive.length) * 10).round / 10d

    aggressionFactor
  }

  def voluntarilyPlayedHands(hands: Seq[Hand], player: String): Seq[Hand] = {
    val voluntarilyPlayed = hands.filter { hand =>
      val playerPosition = hand.positionForPlayer(player)

      val voluntaryAction = hand.preflopEvents.exists {
        case c: Call  => c.seatIndex == playerPosition
        case r: Raise => r.seatIndex == playerPosition
        case _        => false
      }

      voluntaryAction
    }

    voluntarilyPlayed
  }
}
