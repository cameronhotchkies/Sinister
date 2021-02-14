package models

import controllers.HomeController
import io.circe.{Encoder, Json, parser, Error => CError}
import models.opponent.Profile

import java.io.{File, FileInputStream}
import scala.io.Source
import scala.util.hashing.MurmurHash3

case class Participant(
    name: String
) {
  val hash: String = {
    val fwHash = MurmurHash3.stringHash(name)
    val bwHash = MurmurHash3.stringHash(name.reverse)

    f"$fwHash%08x$bwHash%08x"
  }

  lazy val handsPlayed: Int = pastHands.length

  lazy val pastHands: Seq[HandArchive] = {
    val previousHands = handsStoredForPlayer()
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

  private def handsStoredForPlayer(): Seq[File] = {
    val playerDataDir = s"${HomeController.playerData}/${hash}"

    val f: File = new File(playerDataDir)

    val files = f.listFiles()

    if (files != null) {
      files.toIndexedSeq
    } else {
      Nil
    }
  }

  def recentProfile(): Profile = {
    val recentHands =
      pastHands.map(_.hand).sortBy(_.handId)(Ordering.Int.reverse).take(100)
    Profile(recentHands, name)
  }

  def fullTableHands() =
    pastHands
      .map(_.hand)
      .filter(_.playersDealtIn.length >= 7)

  def fullTableProfile(): Profile = {

    val fth = fullTableHands()
    Profile(fth, name)
  }

  lazy val fullTableWinRate: BigDecimal = {
    Profile.bbPer100(fullTableHands(), name)
  }
}
object Participant {
  implicit val encoder: Encoder[Participant] = participant => {
    Json.obj(
      "name" -> Json.fromString(participant.name),
      "handsPlayed" -> Json.fromInt(participant.handsPlayed),
      "hash" -> Json.fromString(participant.hash)
    )
  }
}
