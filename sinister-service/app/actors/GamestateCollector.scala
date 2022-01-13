package actors
import actors.TableRegistry.TableById
import akka.actor.{Actor, ActorRef, Props}
import cats.data.OptionT
import controllers.HomeController
import io.circe.Json
import models._
import models.gamestate.{DealCommunityCard, GameNarrative}
import models.importer.GameState.toHandState
import models.importer.GameStateEvent.{bettingRoundFor, toHandEvent}
import models.importer.GameStateMessage
import play.api.Logger
import play.libs.Scala.emptyMap

import java.io.{BufferedWriter, File, FileOutputStream, FileWriter}
import java.nio.file.{Files, Path, Paths}
import java.time.Instant
import java.util.stream.Collectors
import java.util.zip.{ZipEntry, ZipOutputStream}
import javax.inject.{Inject, Named}
import scala.concurrent.duration.DurationInt
import scala.concurrent.{ExecutionContext, Future}
import scala.jdk.CollectionConverters._

case class IntakeGamestate(
    gameId: Int,
    gamestateData: Json
)

class GamestateCollector @Inject() (
    @Named("table-registry") val tableRegistry: ActorRef,
    @Named("player-registry") val playerRegistry: ActorRef
) extends Actor {
  override def receive: Receive = {
    case IntakeGamestate(gameId, content) => {
      val childName = s"game-${gameId}"

      val target = context
        .child(childName)
        .getOrElse {
          val newChild =
            context.actorOf(Props(new ActiveHand(tableRegistry, playerRegistry)), childName)
          newChild ! ActivateHand(gameId)
          newChild
        }

      target ! RawGamestate(content)
    }
  }
}

case class CheckForCompletion()
case class SummarizeHand()

class ActiveHand(val tableRegistry: ActorRef, val playerRegistry: ActorRef) extends Actor {
  val logger: Logger = Logger("application")

  val initializationTime: Instant = Instant.now()

  def active(
      gameId: Int,
      states: List[Json],
      gameTable: Option[Table]
  ): Receive = {
    case RawGamestate(content) => {
      val newStates = states :+ content
      logger.debug(s"Tracking ${newStates.length} states for $gameId")
      context become active(gameId, newStates, gameTable)

      implicit val ec: ExecutionContext = context.dispatcher
       self ! CheckForCompletion()
    }
    case CheckForCompletion() => {
      logger.debug(s"Table Defined: ${gameTable.isDefined}")
      val mostRecent = states.last
      val gsm = mostRecent.as[GameStateMessage]
      gsm.map(gssm => {
        logger.debug(s"GSSM TS: ${gssm.ts}")

        if (gssm.gameState.additionalData.stage == GameStateAddition.GameOver) {
          implicit val ec: ExecutionContext = context.dispatcher
          context.system.scheduler.scheduleOnce(15.seconds, self, SummarizeHand())
        }

        if (gameTable.isEmpty) {
          val tableId = gssm.gameState.tableId
          tableRegistry ! TableById(tableId)
        }
      })
    }
    case SummarizeHand() => {
      val sources = findSources(states)
      val handSummary = summarizeHand(gameId, states, gameTable)

      implicit val ec: ExecutionContext = context.dispatcher

      val gameNarratives = handSummary.map(h => {
        val events = h.events
        val gameNarrativeEvents = events.filter(_.isInstanceOf[GameNarrative])
        gameNarrativeEvents
      })

      val archive = for {
        narrative <- gameNarratives
        summary <- handSummary
      } yield HandArchive(summary, narrative, sources.map(_.toString))

      archive.foreach { ha => syndicateCompletedHand(ha)}
      handSummary.map { hs =>
        logger.debug(s"HandSummary: $hs")
      }
    }

    case Some(t: Table) => {
      context become active(gameId, states, Some(t))
    }
  }


  def syndicateCompletedHand(handArchive: HandArchive): Unit = {
    val handIsComplete = handArchive.hand.isComplete

    logger.debug(s"HandComplete: ${handIsComplete}")
    if (!handIsComplete) return

        val participants = handArchive.hand.playersDealtIn
          .map(Participant(_))

        participants.foreach { participant =>
          ensurePlayerDirectoryExists(participant)
          registerParticipantAsSeen(participant)
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

  def registerParticipantAsSeen(participant: Participant): Unit = {
    playerRegistry ! PlayerRegistry.PlayerSeen(participant.name)
  }

  def ensurePlayerDirectoryExists(player: Participant): Unit = {
    val playerHash = player.hash
    val playerDataDir = s"${HomeController.playerData}/$playerHash"

    val f = new File(playerDataDir)
    if (!f.exists()) {
      Files.createDirectories(f.toPath)
    }
  }


  def findSources(states: List[Json]) = {
    val ids = states.flatMap(_ \\ "id")
      .map(_.asNumber.getOrElse(0).toString)

    logger.debug(s"Source IDs: ${ids}")
    val handPath = Path.of(HomeController.handSink)


    val matchingFiles = Files.find(handPath,
      1,
      (path, _) => {
      ids.exists(id => {
        val fn = path.getFileName.toString
        fn.contains(id)
      })
    })
      .collect(Collectors.toList[Path])
      .asScala.toList
    val distinctFiles = matchingFiles.distinct
    logger.debug(s"Matching sources: ${matchingFiles} [${matchingFiles.size} / ${distinctFiles.size}]")

    matchingFiles
  }

  def summarizeHand(gameId: Int, states: List[Json], gameTable: Option[Table]) = {
    val messages = states.map(_.as[GameStateMessage])

    val startingChips = messages
      .collectFirst {
        case Right(result) => result
      }
      .map(gameStateMessage =>
        gameStateMessage.gameState.handPlayers.flatten.map { player =>
          player.name -> player.startingChips
        }.toMap
      )
      .getOrElse(emptyMap())

    val handStates = messages
      .flatMap(m => m.toOption.map(gsm => toHandState(gsm.gameState)))

    val events =
      messages.flatMap(gssm => gssm.map(_.events).getOrElse(Nil))

    implicit val ec: ExecutionContext = context.dispatcher
    val gameTableContent = OptionT(Future.successful(gameTable))

    val handSummary = Hand.summarize(
      gameId,
      handStates,
      events.map(toHandEvent),
      initializationTime,
      startingChips,
      gameTableContent
    )

    handSummary
  }

  // Probably unused path
  def augmentIfNeeded(gameStateMessage: GameStateMessage) = {
    val events = gameStateMessage.events
    val augmenting = events.exists(_.isInstanceOf[DealCommunityCard])

    val bettingRound = bettingRoundFor(
      gameStateMessage.gameState.additionalData.stage,
      gameStateMessage.gameState.dealer.cards
    )
  }

  override def receive: Receive = {
    case ActivateHand(gameId) => {
      logger.debug(s"activating ${gameId}")
      context become active(gameId, Nil, None)
    }
  }
}

case class ActivateHand(gameId: Int)
case class RawGamestate(value: Json)
