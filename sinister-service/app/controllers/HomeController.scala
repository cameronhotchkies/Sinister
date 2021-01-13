package controllers

import javax.inject._
import play.api._
import play.api.libs.json.{JsDefined, JsString, JsValue, Json}
import play.api.mvc._

import java.io.{BufferedWriter, File, FileWriter}

/**
  * This controller creates an `Action` to handle HTTP requests to the
  * application's home page.
  */
@Singleton
class HomeController @Inject() (val controllerComponents: ControllerComponents)
    extends BaseController {

  val logger: Logger = Logger(this.getClass)

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
    val stateId = (rawState \ "id").toOption.map(_.toString()).getOrElse("mismatch")

    writeFile(s"$stateId.json", rawState.toString())
  }

  def writeFile(filename: String, s: String): Unit = {
    val file = new File(s"logs/hands/$filename")
    val bw = new BufferedWriter(new FileWriter(file))
    bw.write(s)
    bw.close()
  }
}
