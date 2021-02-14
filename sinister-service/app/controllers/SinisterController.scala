package controllers

import actors.{ActorRoot, PlayerRegistry}
import akka.pattern.ask
import akka.util.Timeout
import models.Participant
import play.api.libs.circe.Circe
import play.api.mvc._

import javax.inject.{Inject, Singleton}
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
}
