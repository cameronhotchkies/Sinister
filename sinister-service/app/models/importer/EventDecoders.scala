package models.importer

import io.circe.generic.semiauto.deriveDecoder
import io.circe.{Decoder, HCursor}
import models.gamestate.{
  DealCommunityCard,
  DealPlayerCard,
  DealerRake,
  BettingCompleted,
  ShowHand,
  SubtractChipsFromPot,
  SubtractChipsFromStack,
  TableMessage,
  TransferAction,
  TransferButton,
  UnknownEvent,
  WinHand,
  WinPot
}

object EventDecoders {

  val dealCommunityCard: Decoder[DealCommunityCard] = Decoder.forProduct1(
    "seat-idx"
  )(DealCommunityCard.apply)

  val dealPlayerCard: Decoder[DealPlayerCard] = Decoder.forProduct1(
    "seat-idx"
  )(DealPlayerCard.apply)

  val dealerRake: Decoder[DealerRake] = deriveDecoder

  val bettingEnds: Decoder[BettingCompleted] = (c: HCursor) => {
    for {
      _ <- c.downField("action").as[Int]
    } yield BettingCompleted()
  }

  val showHand: Decoder[ShowHand] = Decoder.forProduct1(
    "seat-idx"
  )(ShowHand.apply)

  val subtractChipsFromPot: Decoder[SubtractChipsFromPot] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        sidePotIndex <- c.downField("side-pot").as[Int]
        amount <- c.downField("amount").as[Int]
      } yield SubtractChipsFromPot(seatIndex, sidePotIndex, amount)
    }

  val subtractChipsFromStack: Decoder[SubtractChipsFromStack] =
    (c: HCursor) => {
      for {
        chipTarget <- c.downField("seat-idx").as[Int]
        amount <- c.downField("amount").as[Int]
      } yield SubtractChipsFromStack(chipTarget, amount)
    }

  val tableMessage: Decoder[TableMessage] =
    (c: HCursor) => {
      for {
        message <- c.downField("table-msg").as[String]
        messageTarget <- c.downField("seat-idx").as[Int]
      } yield TableMessage(message, messageTarget)
    }

  val transferAction: Decoder[TransferAction] =
    (c: HCursor) => {
      for {
        actionTarget <- c.downField("seat-idx").as[Int]
      } yield TransferAction(actionTarget)
    }

  val transferButton: Decoder[TransferButton] =
    (c: HCursor) => {
      for {
        actionTarget <- c.downField("seat-idx").as[Int]
      } yield TransferButton(actionTarget)
    }

  val unknownEvent: Decoder[UnknownEvent] = (c: HCursor) => {
    for {
      eventType <- c.downField("type").as[Int]
    } yield UnknownEvent(eventType, c.value)
  }

  val winHand: Decoder[WinHand] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        amount <- c.downField("amount").as[Int]
        rawHandDetail <- c.downField("hcm").as[String]
      } yield WinHand(seatIndex, amount, rawHandDetail)
    }

  val winPot: Decoder[WinPot] =
    (c: HCursor) => {
      for {
        seatIndex <- c.downField("seat-idx").as[Int]
        sidePotIndex <- c.downField("action").as[Int]
        amount <- c.downField("amount").as[Int]
      } yield WinPot(seatIndex, sidePotIndex, amount)
    }
}
