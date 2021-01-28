package controllers

import io.circe.generic.semiauto._
import io.circe.syntax._
import io.circe.{Decoder, Encoder, Json, parser}
import models.gamestate.{GameNarrative, HandEvent}
import models.importer.GameState.toHandState
import models.importer.GameStateEvent.toHandEvent
import models.importer.GameStateMessage
import models.{HandArchive, Hand, Participant}
import play.api._
import play.api.libs.circe._
import play.api.mvc._

import java.io.{BufferedWriter, File, FileInputStream, FileWriter}
import java.nio.file.Files
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
                     hands: Seq[HandArchive],
                     gameCount: Int,
                     players: Seq[Participant]
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
  case class MessageWithSource(gameStateMessage: GameStateMessage, source: File)
  implicit def extractMessage(m: MessageWithSource): GameStateMessage = {
    m.gameStateMessage
  }

  def readCachedFiles(cachedFiles: Seq[File]): Seq[MessageWithSource] = {
    cachedFiles.flatMap { rawHandFile =>
      {
        logger.info(s"Opening: $rawHandFile")
        val source = new FileInputStream(rawHandFile)
        val jsonContent = Source.fromInputStream(source).mkString
        val typeDecoder = for {
          messageType <- Decoder[String].prepare(_.downField("t"))
        } yield messageType

        parser.decode(jsonContent)(typeDecoder) match {
          case Right("GameState") =>
            val circeParsed = parser.decode[GameStateMessage](jsonContent)

            circeParsed match {
              case Left(value) =>
                logger.warn(s"parsing error: $value")
                logger.warn(s"Source JSON: $jsonContent")
                None
              case Right(value) =>
                Option(
                  MessageWithSource(value, rawHandFile)
                )
            }
          case _ => None
        }
      }
    }
  }

  def ensurePlayerDirectoryExists(player: Participant): Unit = {
    val playerHash = player.hash
    val playerDataDir = s"${HomeController.playerData}/$playerHash"

    val f = new File(playerDataDir)
    if (!f.exists()) {
      Files.createDirectories(f.toPath)
    }
  }

  def saveSerializedHand(handArchive: HandArchive, player: Participant): Unit = {
    val serializedHand = HandArchive.encoder(handArchive).toString()
    val handId = handArchive.hand.handId
    val filename = s"${HomeController.playerData}/${player.hash}/$handId.json"
    val file = new File(filename)
    val bw = new BufferedWriter(new FileWriter(file))
    bw.write(serializedHand)
    bw.close()
  }

  def syndicateCompletedHands(hands: Seq[HandArchive]): Unit = {
    hands
      .filter { handArchive => handArchive.hand.isComplete }
      .foreach { handArchive =>
        {
          handArchive.hand.playersDealtIn.map { player =>
            val participant = Participant(player, 1)
            ensurePlayerDirectoryExists(participant)
            saveSerializedHand(handArchive, participant)
          }
        }
      }
  }

  def parseLogCache(): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val cachedFiles = enumerateCache()

      val parseCacheFiles = readCachedFiles(cachedFiles)

      val byGameId = parseCacheFiles
        .groupBy(_.gameStateMessage.gameState.gameId)
        .map {
          case (x, y) => x -> y.sortBy(_.id)
        }

      val handDetails = byGameId
        .map {
          case (gameId, messages) =>
            val gameStates = messages
              .sortBy(_.id)
              .map(_.gameState)

            val sources = messages.map(_.source.getName)

            val events = messages
              .flatMap(_.events)
              .map(toHandEvent)

            val handSummary = Hand
              .summarize(gameId, gameStates.map(toHandState), events)

            val filteredEvents: Seq[HandEvent] = events
              .filter(_.isInstanceOf[GameNarrative])

            HandArchive(
              handSummary,
              filteredEvents,
              sources
            )
        }
        .toSeq
        .sortBy(_.hand.handId)

      val gameIds = parseCacheFiles
        .map(gameStateMessage => {
          gameStateMessage.gameState.gameId.toString
        })
        .distinct

      val participants = handDetails
        .flatMap { handArchive =>
          handArchive.hand.playersDealtIn
        }
        .groupBy(a => a)
        .map {
          case (a, b) =>
            Participant(a, b.size)
        }
        .toSeq

      syndicateCompletedHands(handDetails)

      val transformedResult = Result(handDetails, gameIds.length, participants)

      val encoded = deriveEncoder[Result]
        .encodeObject(transformedResult)
        .asJson

      Ok(encoded)
    }

}

object HomeController {
  val playerData = "player_data"
}
