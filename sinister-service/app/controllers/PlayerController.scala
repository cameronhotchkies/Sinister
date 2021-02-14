package controllers

import io.circe.syntax.EncoderOps
import io.circe.{Json, ParsingFailure, parser, Error => CError}
import models.opponent.Profile
import models.{Hand, HandArchive, HeroHand, Participant}
import play.api.Logger
import play.api.libs.circe.Circe
import play.api.mvc._

import java.io.{File, FileInputStream}
import javax.inject.{Inject, Singleton}
import scala.io.Source

@Singleton
class PlayerController @Inject() (
    val controllerComponents: ControllerComponents
) extends BaseController
    with Circe {

  def handsStoredForPlayer(player: String): Seq[File] = {
    val participant = Participant(player)

    val playerDataDir = s"${HomeController.playerData}/${participant.hash}"

    val f: File = new File(playerDataDir)

    f.listFiles().toIndexedSeq
  }

  def enumeratePastHandsForPlayer(
      player: String
  ): Seq[HandArchive] = {
    val previousHands = handsStoredForPlayer(player)
    val parseResults = if (previousHands != null) {
      previousHands.map(handData => {
        val fis = new FileInputStream(handData)
        val jsonContent = Source.fromInputStream(fis).mkString
        val parsed = parser.decode[HandArchive](jsonContent)
        parsed
      })
    } else {
      Seq[Either[CError, HandArchive]]()
    }

    parseResults.collect {
      case Right(a) => a
    }
  }

  val logger = Logger("application")

  def playerStats(player: String): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val enumerated = enumeratePastHandsForPlayer(player).map(_.hand)

      val playedCount = enumerated.length
      val wins = enumerated.filter { hand: Hand =>
        hand.winners().contains(player)
      }

      val overallProfile = Profile(enumerated, player)

      val recentHands =
        enumerated.sortBy(_.handId)(Ordering.Int.reverse).take(100)
      val recentProfile = Profile(recentHands, player)

      val fullTableHands =
        enumerated.filter(_.seatedPlayers.flatten.length >= 7)
      val fullTableProfile = Profile(fullTableHands, player)

      val sixMaxHands =
        enumerated.filter(hand =>
          hand.seatedPlayers.flatten.length <= 4 && hand.seatedPlayers.flatten.length < 7
        )
      val sixMaxProfile = Profile(sixMaxHands, player)

      val shortHanded = {
        enumerated.filter(_.seatedPlayers.flatten.length <= 3)
      }
      val shortHandedProfile = Profile(shortHanded, player)

      val outgoing = Json.obj(
        "seen" -> playedCount.asJson,
        "won" -> Json.fromInt(wins.length),
        "overall" -> overallProfile.asJson,
        "recent" -> recentProfile.asJson,
        "fullTable" -> fullTableProfile.asJson,
        "sixMax" -> sixMaxProfile.asJson,
        "shortHanded" -> shortHandedProfile.asJson
      )
      Ok(outgoing)
    }

  def listHands(player: String): Action[AnyContent] =
    Action {
      val playerHands = enumeratePastHandsForPlayer(player).map(_.hand.handId)
      Ok(playerHands.asJson)
    }

  def handStats(player: String, handId: Int): Action[AnyContent] =
    Action { implicit request: Request[AnyContent] =>
      val participant = Participant(player)

      val handData =
        s"${HomeController.playerData}/${participant.hash}/$handId.json"

      val f: File = new File(handData)

      val parseResult = if (f.exists()) {
        val fis = new FileInputStream(f)
        val jsonContent = Source.fromInputStream(fis).mkString
        val parsed = parser.decode[HandArchive](jsonContent)
        parsed

      } else {
        Left(ParsingFailure)
      }

      val handJson = parseResult
        .map(handArchive => {
          val heroHand = HeroHand(player, handArchive.hand)
          heroHand.asJson
        })
        .getOrElse("".asJson)

      Ok(handJson)
    }

}
