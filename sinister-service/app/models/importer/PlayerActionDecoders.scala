package models.importer

import io.circe.{Decoder, HCursor}
import models.gamestate.playeraction.PlayerAction.{
  BET,
  BIG_BLIND,
  CALL,
  CHECK,
  DO_NOT_SHOW_CARDS,
  FIRST_TO_ACT,
  FOLD,
  MUCK_CARDS,
  RAISE,
  SHOW_CARDS,
  SMALL_BLIND,
  UNKNOWN_PLACTION,
  UNKNOWN_PLACTION_13,
  UNKNOWN_PLACTION_25
}
import models.gamestate.playeraction._
import play.api.Logger

object PlayerActionDecoders {

  val bet: Decoder[Bet] = Decoder.forProduct2(
    "seat-idx",
    "amount"
  )(Bet.apply)

  val bigBlind: Decoder[BigBlind] = Decoder.forProduct2(
    "seat-idx",
    "amount"
  )(BigBlind.apply)

  val call: Decoder[Call] = Decoder.forProduct2(
    "seat-idx",
    "amount"
  )(Call.apply)

  val check: Decoder[Check] = Decoder.forProduct1(
    "seat-idx"
  )(Check.apply)

  val doNotShowCards: Decoder[DoNotShowCards] = Decoder.forProduct1(
    "seat-idx"
  )(DoNotShowCards.apply)

  val firstToAct: Decoder[FirstToAct] = Decoder.forProduct1(
    "seat-idx"
  )(FirstToAct.apply)

  val fold: Decoder[Fold] = Decoder.forProduct1(
    "seat-idx"
  )(Fold.apply)

  val muckCards: Decoder[MuckCards] = Decoder.forProduct1(
    "seat-idx"
  )(MuckCards.apply)

  val raise: Decoder[Raise] = Decoder.forProduct2(
    "seat-idx",
    "amount"
  )(Raise.apply)

  val showCards: Decoder[ShowCards] = Decoder.forProduct1(
    "seat-idx"
  )(ShowCards.apply)

  val smallBlind: Decoder[SmallBlind] = Decoder.forProduct2(
    "seat-idx",
    "amount"
  )(SmallBlind.apply)

  val unknownPlayerAction: Decoder[UnknownPlayerAction] = (c: HCursor) => {
    for {
      subAction <- c.downField("action").as[Int]
    } yield UnknownPlayerAction(subAction, c.value)
  }

  val logger: Logger = Logger("application")

  implicit def importDecoder: Decoder[PlayerAction] =
    for {
      plactionType <- Decoder[Int].prepare(_.downField("action"))
      value <- plactionType match {
        case BET                 => bet
        case BIG_BLIND           => bigBlind
        case CALL                => call
        case CHECK               => check
        case DO_NOT_SHOW_CARDS   => doNotShowCards
        case FIRST_TO_ACT        => firstToAct
        case FOLD                => fold
        case MUCK_CARDS          => muckCards
        case RAISE               => raise
        case SHOW_CARDS          => showCards
        case SMALL_BLIND         => smallBlind
        case UNKNOWN_PLACTION    => unknownPlayerAction
        case UNKNOWN_PLACTION_13 => unknownPlayerAction
        case UNKNOWN_PLACTION_25 => unknownPlayerAction
        case _ =>
          logger.info(s"PLACTION: $plactionType")
          ???
      }
    } yield value
}
