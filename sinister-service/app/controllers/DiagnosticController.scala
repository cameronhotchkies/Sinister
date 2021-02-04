package controllers

import actors.{ActorRoot, TableRegistry}
import io.circe.{Json, parser}
import models.Table
import play.api.Logger
import play.api.libs.circe.Circe
import play.api.mvc.{
  Action,
  AnyContent,
  BaseController,
  ControllerComponents,
  Request
}

import javax.inject.Inject

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
}
