package controllers

import actors.PlayerRegistry.{PlayerSeen, RecentPlayers}
import actors.TableRegistry.ListTables
import actors.{ActorRoot, TableRegistry}
import akka.pattern.ask
import akka.util.Timeout
import io.circe.parser
import io.circe.syntax.EncoderOps
import models.Table
import play.api.Logger
import play.api.libs.circe.Circe
import play.api.mvc._

import javax.inject.Inject
import scala.concurrent.ExecutionContext
import scala.concurrent.duration.DurationInt
import scala.language.postfixOps

class DiagnosticController @Inject() (
    val controllerComponents: ControllerComponents,
    val actorRoot: ActorRoot
) extends BaseController
    with Circe {

  val logger = Logger("application")

  def addTable(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val postBody = request.body.asText.getOrElse("")
      val decoded = parser.decode[Table](postBody)

      decoded match {
        case Right(table) => {
          logger.info(s"tbl: $table")
          actorRoot.tableRegistry ! TableRegistry.AddTables(List(table))
        }
      }

      Ok("")
    }

  def listTables(): Action[AnyContent] =
    Action.async {

      implicit val timeout: Timeout = 6 seconds
      implicit val ec: ExecutionContext = controllerComponents.executionContext

      val response = actorRoot.tableRegistry ? ListTables

      response.map {
        case tables: Seq[Table] =>
          Ok(tables.asJson)
      }
    }

  def recentPlayers(): Action[AnyContent] =
    Action.async {

      implicit val timeout: Timeout = 6 seconds
      implicit val ec: ExecutionContext = controllerComponents.executionContext

      val response = actorRoot.playerRegistry ? RecentPlayers

      response.map {
        case players: Seq[String] =>
          Ok(players.asJson)
      }
    }

  def setRecentPlayers(): Action[AnyContent] =
    Action.async { request =>
      implicit val timeout: Timeout = 6 seconds
      implicit val ec: ExecutionContext = controllerComponents.executionContext

      val postBody = request.body.asText.getOrElse("")
      val decoded = parser.decode[Seq[String]](postBody)

      decoded.map { players: Seq[String] =>
        players.foreach { player =>
          actorRoot.playerRegistry ! PlayerSeen(player)
        }
      }

      val response = actorRoot.playerRegistry ? RecentPlayers

      response.map {
        case players: Seq[String] =>
          Ok(players.asJson)
      }
    }
}
