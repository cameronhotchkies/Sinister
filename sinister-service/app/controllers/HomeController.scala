package controllers

import io.circe.generic.semiauto._
import io.circe.syntax._
import io.circe.{Decoder, Encoder, Json, parser}
import models.gamestate.{GameNarrative, HandEvent}
import models.importer.GameState.toHandState
import models.importer.GameStateEvent.toHandEvent
import models.importer.GameStateMessage
import models.{Hand, HandArchive, Participant}
import play.api._
import play.api.libs.circe._
import play.api.mvc._

import java.io.{BufferedWriter, File, FileInputStream, FileWriter}
import java.nio.file.{Files, Paths}
import java.time.Instant
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

      if (bodyText.nonEmpty && bodyText != "null") {
        val parsed = parser.parse(bodyText)

        // logger.info(s"BT: $bodyText")

        parsed.map(bodyJson => {
          val ts = (bodyJson \\ "t")
          if (ts.isEmpty) {
            logger.info(s"BT: $bodyText")
          } else {
            val t = (bodyJson \\ "t").head.as[String]
            t.getOrElse("--skipped--") match {
              case "GameState" =>
                logGameState(bodyJson)
              case x => logger.warn(s"skipped: $x")
            }
          }
        })
      }

      Ok("sunk")
    }

  def logGameState(rawState: Json): Unit = {
    val stateId =
      (rawState \\ "id").head
        .as[Int]
        .map(_.toString())
        .getOrElse("mismatch")

    val ts = Instant.now().toEpochMilli
    writeFile(s"$ts-$stateId.json", rawState.toString())
  }

  def writeFile(filename: String, s: String): Unit = {
    val file = new File(s"${HomeController.handSink}/$filename")
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
    val d = new File(s"${HomeController.handSink}")
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

  def saveSerializedHand(
      handArchive: HandArchive,
      player: Participant
  ): Unit = {
    val serializedHand = HandArchive.encoder(handArchive).toString()
    val handId = handArchive.hand.handId
    val filename = s"${HomeController.playerData}/${player.hash}/$handId.json"
    val file = new File(filename)
    val bw = new BufferedWriter(new FileWriter(file))
    bw.write(serializedHand)
    bw.close()
  }

  def compressSources(handArchive: HandArchive): Option[String] = {
    import java.io.FileOutputStream
    import java.util.zip.ZipOutputStream
    import java.util.zip.ZipEntry
    import java.nio.file.Files
    import java.nio.file.Paths
    val zipFileName = new File(
      s"${HomeController.playerData}/${handArchive.hand.handId}.zip"
    )

    val fos = new FileOutputStream(zipFileName)
    val zos = new ZipOutputStream(fos)

    handArchive.sources.foreach { sourceFilename =>
      val sourceFile = s"${HomeController.handSink}/$sourceFilename"

      zos.putNextEntry(new ZipEntry(sourceFile))
      val bytes: Array[Byte] = Files.readAllBytes(Paths.get(sourceFile))
      zos.write(bytes, 0, bytes.length)
      zos.closeEntry()
    }

    zos.close()
    val compressed = zipFileName.length()
    logger.info(s"Compressed: $zipFileName [$compressed]")

    if (compressed > 0) {
      Option(zipFileName.getName)
    } else {
      None
    }
  }

  def syndicateCompletedHands(hands: Seq[HandArchive]): Unit = {
    val handCount = hands.length

    val completedHands = hands
      .filter { handArchive => handArchive.hand.isComplete }

    logger.info(s"${completedHands.length} completed out of $handCount")

    completedHands.foreach { handArchive =>
      {
        handArchive.hand.playersDealtIn.foreach { player =>
          val participant = Participant(player, 1)
          ensurePlayerDirectoryExists(participant)
          saveSerializedHand(handArchive, participant)
        }

        val compressedFile = compressSources(handArchive)
        compressedFile.foreach(_ => {
          handArchive.sources.foreach { sourceFile =>
            val path = Paths.get(s"${HomeController.handSink}/$sourceFile")
            Files.delete(path)
          }
        })
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

            val startTime = messages
              .map(_.gameStateMessage.ts)
              .map(Instant.ofEpochMilli)
              .min

            val handSummary = Hand
              .summarize(gameId, gameStates.map(toHandState), events, startTime)

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

  val handSink = "logs/hands"
}
