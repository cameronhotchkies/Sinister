package models.gamestate

import io.circe.{Decoder, Encoder, HCursor, Json}
import models.gamestate.playeraction.PlayerAction

trait GameStateEvent {
  def encoded: Json
}

object GameStateEvent {
  implicit val decoder: Decoder[GameStateEvent] = (c: HCursor) => {
    for {
      eventType <- c.downField("type").as[Int]
    } yield interpret(eventType, c.value)
  }

  val DEAL_PLAYER = 1
  val DEAL_COMMUNITY = 2
  val NEXT_STAGE = 3
  val SUBTRACT_CHIPS_FROM_STACK = 4
  val TRANSFER_BUTTON = 5
  val TRANSFER_ACTION = 6
  val SUBTRACT_CHIPS_FROM_POT = 7
  val DEALER_RAKE = 8
  val PLAYER_ACTION = 9
  val WIN_HAND = 10
  val WIN_POT = 12
  val TABLE_MESSAGE = 15
  val SHOW_HAND = 25

  def interpret(eventType: Int, rawJson: Json): GameStateEvent = {
    rawJson.asObject
      .map[GameStateEvent] { jso =>
        val seatIndex = (rawJson \\ "seat-idx").head.as[Int].getOrElse(-227)
        eventType match {
          case DEAL_PLAYER    => DealPlayerCard(seatIndex)
          case DEAL_COMMUNITY => DealCommunityCard(seatIndex)
          case NEXT_STAGE     => EnterNextStage
          case SUBTRACT_CHIPS_FROM_STACK =>
            val chipAmount = jso("amount").flatMap(_.asNumber.flatMap(_.toInt))
            SubtractChipsFromStack(seatIndex, chipAmount.getOrElse(0))
          case TRANSFER_BUTTON =>
            TransferButtonEvent.decoder
              .decodeJson(rawJson)
              .getOrElse(TransferButtonEvent(-144))
          case TRANSFER_ACTION =>
            TransferActionEvent.decoder
              .decodeJson(rawJson)
              .getOrElse(UnknownEvent(-6, rawJson))
          case SUBTRACT_CHIPS_FROM_POT =>
            SubtractChipsFromPot.decoder
              .decodeJson(rawJson)
              .getOrElse(SubtractChipsFromPot(-182, -182, -182))

          case DEALER_RAKE =>
            DealerRake.decoder
              .decodeJson(rawJson)
              .getOrElse(DealerRake(-1))
          case PLAYER_ACTION => PlayerAction.interpret(rawJson)
          case WIN_HAND =>
            WinHandEvent.decoder
              .decodeJson(rawJson)
              .getOrElse(???)
          case WIN_POT =>
            WinPotEvent.decoder
              .decodeJson(rawJson)
              .getOrElse(???)
          case TABLE_MESSAGE =>
            TableMessage.decoder
              .decodeJson(rawJson)
              .getOrElse(TableMessage("could not parse", -134))
          case SHOW_HAND => ShowHand(seatIndex)
          case _         => UnknownEvent(eventType, rawJson)
        }
      }
      .getOrElse(UnknownEvent(0, rawJson))
  }

  implicit val encoder: Encoder[GameStateEvent] =
    (gameStateEvent: GameStateEvent) => {
      gameStateEvent.encoded
    }
}
