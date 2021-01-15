package controllers

import models.{GameStateMessage, HandSummary}
import play.api._
import play.api.libs.json._
import play.api.mvc._

import java.io.{BufferedWriter, File, FileInputStream, FileWriter}
import javax.inject._

/**
  * This controller creates an `Action` to handle HTTP requests to the
  * application's home page.
  */
@Singleton
class HomeController @Inject() (val controllerComponents: ControllerComponents)
    extends BaseController {

  val logger: Logger = Logger("application")

  /**
    * Create an Action to render an HTML page.
    *
    * The configuration in the `routes` file means that this method
    * will be called when the application receives a `GET` request with
    * a path of `/`.
    */
  def index(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      Ok(views.html.index())
    }

  def sink(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val bodyJson = Json.parse(request.body.asText.getOrElse(""))

      val messageType = bodyJson \ "t"

      messageType match {
        case JsDefined(JsString("GameState")) =>
          logGameState(bodyJson)
        case default => logger.warn("skipped")
      }

      Ok("sunk")
    }

  def logGameState(rawState: JsValue): Unit = {
    val stateId =
      (rawState \ "id").toOption.map(_.toString()).getOrElse("mismatch")

    writeFile(s"$stateId.json", rawState.toString())
  }

  def writeFile(filename: String, s: String): Unit = {
    val file = new File(s"logs/hands/$filename")
    val bw = new BufferedWriter(new FileWriter(file))
    bw.write(s)
    bw.close()
  }

  case class Result(hands: Seq[HandSummary], gameCount: Int)
  object Result {
    implicit val writes: Writes[Result] = Json.writes[Result]
  }

  def enumerateCache(): List[File] = {
    val d = new File("logs/hands")
    if (d.exists && d.isDirectory) {
      d.listFiles.filter(_.isFile).toList
    } else {
      List[File]()
    }

  }

  def parseLogCache(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>

      val cachedFiles = enumerateCache()

      val parseCacheFiles = cachedFiles.flatMap { rawHandFile =>
        {
          val source = new FileInputStream(rawHandFile)
          val parsed = Json.parse(source)
          Json.fromJson[GameStateMessage](parsed) match {
            case JsSuccess(value, path) =>
              Option(value)
            case JsError(errors) =>
              logger.error(s"PRSED: $parsed")
              logger.error(errors.toString())
              None
          }
        }
      }

      val byGameId = parseCacheFiles.groupBy(_.gameState.gameId)
      val handDetails = byGameId.map {
        case (gameId, messages) =>
          logger.info(s"MSGS: $messages")
          val gameStates = messages
            .sortBy(_.id)
            .map(_.gameState)

          HandSummary.summarize(gameId, gameStates)
      }
        .toSeq
        .sortBy(_.handId)

      logger.info(s"PBH: $handDetails")

      val gameIds = parseCacheFiles
        .map(gameStateMessage => {
          gameStateMessage.gameState.gameId.toString
        })
        .distinct

      val transformedResult = Result(handDetails, gameIds.length)

      Ok(Json.toJson(transformedResult))

    }

}
