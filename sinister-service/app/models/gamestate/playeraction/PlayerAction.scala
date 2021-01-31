package models.gamestate.playeraction

import io.circe.syntax.EncoderOps
import io.circe.{Decoder, Encoder}
import models.gamestate.{AppliesToPlayer, GameNarrative, HandEvent}
import models.importer.GameStateEvent
import play.api.Logger

trait PlayerAction
    extends GameStateEvent
    with GameNarrative
    with AppliesToPlayer
    with HandEvent

object PlayerAction {

  val FOLD = 1
  val CHECK = 2
  val CALL = 3
  val SMALL_BLIND = 6
  val BIG_BLIND = 7
  val BET = 8
  val RAISE = 9
  val SHOW_CARDS = 10
  val MUCK_CARDS = 11
  val UNKNOWN_PLACTION = 15
  val DO_NOT_SHOW_CARDS = 16
  val UNKNOWN_PLACTION_25 = 25
  val FIRST_TO_ACT = 26

  val logger = Logger("application")

  implicit val decoderPlayerAction: Decoder[PlayerAction] = for {
    plactionType <- Decoder[Int].prepare(_.downField("plaction"))
    value <- plactionType match {
      case BET                 => Bet.decoder
      case BIG_BLIND           => BigBlind.decoder
      case CALL                => Call.decoder
      case CHECK               => Check.decoder
      case DO_NOT_SHOW_CARDS   => DoNotShowCards.decoder
      case FIRST_TO_ACT        => FirstToAct.decoder
      case FOLD                => Fold.decoder
      case MUCK_CARDS          => MuckCards.decoder
      case RAISE               => Raise.decoder
      case SHOW_CARDS          => ShowCards.decoder
      case SMALL_BLIND         => SmallBlind.decoder
      case UNKNOWN_PLACTION    => UnknownPlayerAction.decoder
      case UNKNOWN_PLACTION_25 => UnknownPlayerAction.decoder
      case other => {
        logger.error(s"Unhandled Plaction: $plactionType")
        ???
      }
    }
  } yield value

  implicit val encodePlayerAction: Encoder.AsObject[PlayerAction] =
    Encoder.AsObject {
      case b: Bet => b.asJsonObject.add("plaction", BET.asJson)
      case bb: BigBlind =>
        bb.asJsonObject.add("plaction", BIG_BLIND.asJson)
      case c: Call  => c.asJsonObject.add("plaction", CALL.asJson)
      case c: Check => c.asJsonObject.add("plaction", CHECK.asJson)
      case dnsc: DoNotShowCards =>
        dnsc.asJsonObject
          .add("plaction", DO_NOT_SHOW_CARDS.asJson)
      case fta: FirstToAct =>
        fta.asJsonObject
          .add("plaction", FIRST_TO_ACT.asJson)
      case f: Fold       => f.asJsonObject.add("plaction", FOLD.asJson)
      case mc: MuckCards => mc.asJsonObject.add("plaction", MUCK_CARDS.asJson)
      case r: Raise =>
        r.asJsonObject.add("plaction", RAISE.asJson)
      case sb: SmallBlind =>
        sb.asJsonObject.add("plaction", SMALL_BLIND.asJson)
      case sc: ShowCards => sc.asJsonObject.add("plaction", SHOW_CARDS.asJson)
      case upa: UnknownPlayerAction =>
        upa.asJsonObject.add("plaction", UNKNOWN_PLACTION.asJson)
    }
}
