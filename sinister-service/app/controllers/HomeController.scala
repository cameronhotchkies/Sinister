package controllers

import io.circe.generic.semiauto._
import io.circe.syntax._
import io.circe.{Encoder, Json, parser}
import models.gamestate.GameNarrative
import models.{GameStateMessage, Hand, HandSummary}
import play.api._
import play.api.libs.circe._
import play.api.mvc._

import java.io.{BufferedWriter, File, FileInputStream, FileWriter}
import javax.inject._
import scala.io.Source

/**
  * This controller creates an `Action` to handle HTTP requests to the
  * application's home page.
  */
@Singleton
class HomeController @Inject() (val controllerComponents: ControllerComponents)
    extends BaseController
    with Circe {

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
      val bodyText = request.body.asText.getOrElse("")

      val parsed = parser.parse(bodyText)

      parsed.map(bodyJson => {
        val t = (bodyJson \\ "t").head.as[String]
        t.getOrElse("--skipped--") match {
          case "GameState" =>
            logGameState(bodyJson)
          case x => logger.warn(s"skipped: $x")
        }
      })

      Ok("sunk")
    }

  def logGameState(rawState: Json): Unit = {
    val stateId =
      (rawState \\ "id").head
        .as[Int]
        .map(_.toString())
        .getOrElse("mismatch")

    writeFile(s"$stateId.json", rawState.toString())
  }

  def writeFile(filename: String, s: String): Unit = {
    val file = new File(s"logs/hands/$filename")
    val bw = new BufferedWriter(new FileWriter(file))
    bw.write(s)
    bw.close()
  }

  case class Result(
      hands: Seq[Hand],
      gameCount: Int,
      players: Seq[(String, Int)]
  )
  object Result {
    implicit val encoder: Encoder[Result] = deriveEncoder
  }

  def enumerateCache(): List[File] = {
    val d = new File("logs/hands")
    if (d.exists && d.isDirectory) {
      d.listFiles
        .filter(_.isFile)
        .filter(_.getName.endsWith("json"))
        .toList
    } else {
      List[File]()
    }
  }

  def parseLogCache(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val cachedFiles = enumerateCache()

      val parseCacheFiles: Seq[GameStateMessage] = cachedFiles
        .flatMap { rawHandFile =>
          {
            logger.info(s"Opening: $rawHandFile")
            val source = new FileInputStream(rawHandFile)
            val jsonContent = Source.fromInputStream(source).mkString
            val circeParsed = parser.decode[GameStateMessage](jsonContent)

            circeParsed match {
              case Left(value) =>
                logger.warn(s"parsing error: $value")
                None
              case Right(value) => Option(value)
            }
          }
        }

      val byGameId = parseCacheFiles
        .groupBy(_.gameState.gameId)
        .map {
          case (x, y) => x -> y.sortBy(_.id)
        }

      val handDetails = byGameId
        .map {
          case (gameId, messages) =>
            val gameStates = messages
              .sortBy(_.id)
              .map(_.gameState)

            val events = messages
              .flatMap(_.events)

            val handSummary = HandSummary
              .summarize(gameId, gameStates, events)

            val filteredEvents = events.filter(_.isInstanceOf[GameNarrative])

            if (gameId == 75578234) {
              logger.info(s"filtered: $filteredEvents")

            }
            Hand(handSummary, filteredEvents)
        }
        .toSeq
        .sortBy(_.summary.handId)

//      logger.info(s"Hand Details: $handDetails")

      val gameIds = parseCacheFiles
        .map(gameStateMessage => {
          gameStateMessage.gameState.gameId.toString
        })
        .distinct

      val participants = handDetails.flatMap { hand =>
        hand.summary.playersDealtIn
      }
        .groupBy(a => a)
        .map(s => (s._1, s._2.size))
        .toSeq

      val transformedResult = Result(handDetails, gameIds.length, participants)

      val encoded = deriveEncoder[Result]
        .encodeObject(transformedResult)
        .asJson

      Ok(encoded)
    }

}
