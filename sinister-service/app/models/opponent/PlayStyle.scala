package models.opponent

import io.circe.Encoder
import io.circe.generic.semiauto.deriveEncoder
import io.circe.syntax.EncoderOps
import models.opponent.PlayStyle.{Aggressive, Loose, Passive, SemiLoose, Tight, VeryLoose, VeryTight}

import scala.math.BigDecimal.RoundingMode

case class PlayStyle(
    vpip: BigDecimal,
    pfr: BigDecimal,
    aggressionRatio: BigDecimal,
    aggressionFactor: BigDecimal
) {

  def playType(): String = {
    if (vpip + pfr + aggressionFactor +aggressionRatio == 0) {
      "learning..."
    } else {
      val frequency = if (vpip <= 14) {
        PlayStyle.VeryTight
      } else if (14 < vpip && vpip <= 23) {
        PlayStyle.Tight
      } else if (23 < vpip && vpip <= 32) {
        PlayStyle.SemiLoose
      } else if (32 < vpip && vpip <= 40) {
        PlayStyle.Loose
      } else if (40 < vpip) {
        PlayStyle.VeryLoose
      } else {
        PlayStyle.Mismatch
      }

      val betStyle = if (aggressionRatio >= 7) {
        PlayStyle.Aggressive
      } else {
        PlayStyle.Passive
      }

      val category = (frequency, betStyle) match {

        case (VeryTight, Passive) => "rock+"
        case (VeryTight, Aggressive) => "nit"
        case (Tight, Passive) => "rock"
        case (Tight, Aggressive) => "TAG"
        case (SemiLoose, Passive) => "fish"
        case (SemiLoose, Aggressive) => "regular"
        case (Loose, Passive) => "call-station"
        case (Loose, Aggressive) => "LAG"
        case (VeryLoose, Passive) => "whale"
        case (VeryLoose, Aggressive) => "maniac"
        case _ => "uk"
      }

      s"$frequency/$betStyle/$category"
    }
  }
}

object PlayStyle {
  val VeryTight = "VT"
  val Tight = "T"
  val SemiLoose = "SL"
  val Loose = "L"
  val VeryLoose = "VL"
  val Mismatch = "mm"

  val Aggressive = "AG"
  val Passive = "P"

  def apply( vpip: Double,
             pfr: Double,
             aggressionRatio: Double,
             aggressionFactor: Double): PlayStyle = {

    def rbd(d: Double) = {
      BigDecimal(d).setScale(2, RoundingMode.HALF_UP)
    }

    PlayStyle(rbd(vpip), rbd(pfr), rbd(aggressionRatio),rbd(aggressionFactor))
  }

  implicit val encoder: Encoder.AsObject[PlayStyle] = (ps: PlayStyle) => {
    deriveEncoder[PlayStyle]
      .encodeObject(ps)
      .add(
        "playType",
        ps.playType().asJson
      )
  }
}
