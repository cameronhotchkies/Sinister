package controllers

import actors.{ActorRoot, PlayerRegistry}
import akka.pattern.ask
import akka.util.Timeout
import models.gamestate.GameNarrative
import models.{Boundary, HeroHand, Participant}
import play.api.Logger
import play.api.libs.circe.Circe
import play.api.mvc._

import javax.inject.{Inject, Singleton}
import scala.concurrent.Future
import scala.concurrent.duration.DurationInt
import scala.language.postfixOps

@Singleton
class SinisterController @Inject() (
    val controllerComponents: ControllerComponents,
    val actorRoot: ActorRoot,
    val playerController: PlayerController
) extends BaseController
    with Circe {

  implicit val ec = controllerComponents.executionContext

  def recentPlayers: Action[AnyContent] =
    Action.async { implicit request: Request[AnyContent] =>
      implicit val timeout: Timeout = 6 seconds
      val response = actorRoot.playerRegistry ? PlayerRegistry.RecentPlayers

      response.map {
        case s: Seq[String] => {
          val participants = s.map(Participant(_))
          Ok(views.html.recent_players(participants))
        }
      }
    }

  val logger = Logger("application")

  def handOverview(playerName: String, handId: Int): Action[AnyContent] =
    Action.async { implicit request: Request[AnyContent] =>
      val participant = Participant(playerName)

      participant
        .handById(handId)
        .fold {
          Future.successful(NotFound("Hand Not Found"))
        } { heroHand =>
          val narrativeEvents = heroHand.hand.events
            .filter(_.isInstanceOf[GameNarrative])

          implicit val seats = heroHand.hand.seatedPlayers
          val narratives = narrativeEvents
            .map(_.asInstanceOf[GameNarrative].narrative)

          Future.successful(
            Ok(
              views.html.hand_overview(heroHand, narratives)
            )
          )
        }
    }

  def playerOverview(playerName: String): Action[AnyContent] =
    Action.async { implicit request: Request[AnyContent] =>
      val participant = Participant(playerName)

      val fullTableHands = participant.fullTableHands()

      val winningExtremes =
        participant.fullTableHands().foldLeft(Boundary.ZERO) { (acc, hand) =>
          val hh = HeroHand(playerName, hand)
          hh.bigBlindsWon().fold(acc) { winnings =>
            if (winnings > acc.min && winnings < acc.max) {
              acc
            } else if (winnings < acc.min) {
              acc.copy(min = winnings, worstHands = List(hand))
            } else if (winnings > acc.max) {
              acc.copy(max = winnings, bestHands = List(hand))
            } else if (winnings == acc.min) {
              acc.copy(worstHands = acc.worstHands.appended(hand))
            } else if (winnings == acc.max) {
              acc.copy(bestHands = acc.bestHands.appended(hand))
            } else {
              logger.debug(s"Corner case $acc / $hand")
              acc
            }
          }
        }

      Future.successful(
        Ok(views.html.player_overview(participant, winningExtremes))
      )
    }
}
