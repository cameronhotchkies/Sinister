package controllers

import io.circe.syntax.EncoderOps
import io.circe.{Json, parser, Error => CError}
import models.gamestate.playeraction.{Bet, Call, Raise}
import models.gamestate.{AppliesToPlayer, HandEvent}
import models.opponent.PlayStyle
import models.{Hand, HandArchive, Participant}
import play.api.Logger
import play.api.libs.circe.Circe
import play.api.mvc._

import java.io.{File, FileInputStream}
import javax.inject.{Inject, Singleton}
import scala.io.Source

@Singleton
class PlayerController @Inject() (
    val controllerComponents: ControllerComponents
) extends BaseController
    with Circe {

  def enumeratePastHandsForPlayer(
      player: String
  ): Array[Either[CError, HandArchive]] = {
    val participant = Participant(player, -1)

    val playerDataDir = s"${HomeController.playerData}/${participant.hash}"

    val f: File = new File(playerDataDir)

    val previousHands = f.listFiles()
    if (previousHands != null) {
      previousHands.map(handData => {
        val fis = new FileInputStream(handData)
        val jsonContent = Source.fromInputStream(fis).mkString
        val parsed = parser.decode[HandArchive](jsonContent)
        parsed
      })
    } else {
      Array[Either[CError, HandArchive]]()
    }
  }

  val logger = Logger("application")

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
      .reduce(_ + _)

    val aggressionFactor =
      ((playerWagers.aggressor.length.toDouble / playerWagers.passive.length) * 10).round / 10d

    aggressionFactor
  }

  def playerStats(player: String): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val enumerated = enumeratePastHandsForPlayer(player).flatMap {
        case Right(h: HandArchive) => Some(h.hand)
        case Left(_)               => None
      }

      val playedCount = enumerated.length

      val voluntaryPlayed = voluntarilyPlayedHands(enumerated, player)

      val aggressivelyPlayed = voluntaryPlayed.filter(hand => {
        val playerPosition = hand.positionForPlayer(player)
        val aggressiveAction = hand.preflopEvents.exists {
          case r: Raise => r.seatIndex == playerPosition
          case _        => false
        }

        aggressiveAction
      })

      val aggressionFactor = calculateAggressionFactor(player, enumerated)

      val vpipHands = voluntaryPlayed.length
      val pfrHands = aggressivelyPlayed.length

      val vpip = ((vpipHands.toDouble / playedCount) * 1000).round / 10f
      val pfr = ((pfrHands.toDouble / playedCount) * 1000).round / 10f
      val wins = enumerated.filter { hand: Hand =>
        hand.winners().contains(player)
      }

      val aggressionRatio = ((pfr / vpip) * 1000).round / 100f

      val playStyle = PlayStyle(vpip, pfr, aggressionRatio, aggressionFactor)

      val outgoing = Json.obj(
        "seen" -> Json.fromInt(enumerated.length),
        "won" -> Json.fromInt(wins.length),
        "playStyle" -> playStyle.asJson
      )
      Ok(outgoing)
    }
}
