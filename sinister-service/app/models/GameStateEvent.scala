package models

import io.circe.generic.semiauto.{deriveDecoder, deriveEncoder}
import io.circe.{Decoder, Encoder, HCursor, Json}

trait GameStateEvent {
  def encoded: Json
}

case class UnknownEvent(`type`: Int, raw: Json) extends GameStateEvent {
  def encoded: Json = UnknownEvent.encoded(this)
}
object UnknownEvent {
  implicit val encoded: Encoder[UnknownEvent] = deriveEncoder
}

case class TransferActionEvent(actionToSeat: Int) extends GameStateEvent {
  override def encoded: Json = TransferActionEvent.encoder(this)
}
object TransferActionEvent {
  implicit val encoder: Encoder[TransferActionEvent] = deriveEncoder

  implicit val decoder: Decoder[TransferActionEvent] =
    (c: HCursor) => {
      for {
        actionTarget <- c.downField("seat-idx").as[Int]
      } yield TransferActionEvent(actionTarget)
    }
}

case class PlayerAction(subAction: Int, rawJson: Json) extends GameStateEvent {
  val encoded: Json = {
    Json.obj(
      "undefinedPlayerAction" -> Json.fromBoolean(true),
      "subAction" -> Json.fromInt(subAction),
      "source" -> rawJson
    )
  }
}

object PlayerAction {

  private val FOLD = Some(1)
  private val CHECK = Some(2)
  private val CALL = Some(3)
  private val SMALL_BLIND = Some(6)
  private val BIG_BLIND = Some(7)
  private val BET = Some(8)
  private val RAISE = Some(9)
  private val SHOW_CARDS = Some(10)
  private val DO_NOT_SHOW_CARDS = Some(16)

  def interpret(rawJson: Json): GameStateEvent = {

    rawJson.asObject
      .map(jso => {

        val actionType = jso("action").flatMap(_.asNumber.flatMap(_.toInt))
        val extractedSeatIndex =
          jso("seat-idx").flatMap(_.asNumber.flatMap(_.toInt))
        val extractedAmount = jso("amount").flatMap(_.asNumber.flatMap(_.toInt))

        val playerAction =
          (actionType, extractedSeatIndex, extractedAmount) match {

            case (None, _, _) => ???
            case (FOLD, Some(seatIndex), _) =>
              PlayerFold(seatIndex)
            case (CHECK, Some(seatIndex), _) =>
              PlayerCheck(seatIndex)
            case (CALL, Some(seatIndex), Some(amount)) =>
              PlayerActionCall(seatIndex, amount)
            case (SMALL_BLIND, Some(seatIndex), Some(amount)) =>
              SmallBlind(seatIndex, amount)
            case (BIG_BLIND, Some(seatIndex), Some(amount)) =>
              BigBlind(seatIndex, amount)
            case (BET, Some(seatIndex), Some(amount)) =>
              Bet(seatIndex, amount)
            case (RAISE, Some(seatIndex), Some(amount)) =>
              Raise(seatIndex, amount)
            case (SHOW_CARDS, Some(seatIndex), _) =>
              ShowCards(seatIndex)
            case (DO_NOT_SHOW_CARDS, Some(seatIndex), _) =>
              DoNotShowCards(seatIndex)
            case (Some(actionType), _, _) => PlayerAction(actionType, rawJson)
          }

        playerAction
      })
      .getOrElse(PlayerAction(-89, rawJson))
  }
}

case class SmallBlind(seatIndex: Int, amount: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj(
      "smallBlind" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )
  }
}

case class BigBlind(seatIndex: Int, amount: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj(
      "bigBlind" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )
  }
}

case class Bet(seatIndex: Int, amount: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj(
      "bet" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )
  }
}

case class Raise(seatIndex: Int, amount: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj(
      "raise" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )
  }
}

case class PlayerActionCall(seatIndex: Int, amount: Int)
    extends GameStateEvent {
  def encoded: Json = {
    Json.obj(
      "call" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )
  }
}

case class PlayerFold(seatIndex: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj("playerFold" -> Json.fromInt(seatIndex))
  }
}

case class PlayerCheck(seatIndex: Int) extends GameStateEvent {
  def encoded: Json = {
    Json.obj("playerCheck" -> Json.fromInt(seatIndex))
  }
}

case class DealPlayerCard(seatIndex: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "dealCard" -> Json.fromInt(seatIndex)
    )
}

case class ShowHand(seatIndex: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "showHand" -> Json.fromInt(seatIndex)
    )
}

case class ShowCards(seatIndex: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "showCards" -> Json.fromInt(seatIndex)
    )
}

case class DoNotShowCards(seatIndex: Int) extends GameStateEvent {

  override def encoded: Json =
    Json.obj(
      "doNotShowCards" -> Json.fromInt(seatIndex)
    )
}

case class SubtractChips(seatIndex: Int, amount: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "subtractChips" -> Json.fromInt(amount),
      "player" -> Json.fromInt(seatIndex)
    )

}

case class DealerRake(amount: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "rake" -> Json.fromInt(amount)
    )

  implicit val decoder: Decoder[DealerRake] = deriveDecoder
}

case class DealCommunityCard(seatIndex: Int) extends GameStateEvent {
  override def encoded: Json =
    Json.obj(
      "dealCommunityCard" -> Json.fromBoolean(true)
    )
}

case object EnterNextPhase extends GameStateEvent {
  def apply(): Any = ???

  override def encoded: Json = {
    Json.obj("nextPhase" -> Json.fromBoolean(true))
  }
}

object GameStateEvent {
  implicit val decoder: Decoder[GameStateEvent] = (c: HCursor) => {
    for {
      eventType <- c.downField("type").as[Int]
    } yield interpret(eventType, c.value)
  }

  def interpret(eventType: Int, rawJson: Json): GameStateEvent = {
    rawJson.asObject
      .map[GameStateEvent] { jso =>
        val seatIndex = (rawJson \\ "seat-idx").head.as[Int].getOrElse(-227)
        eventType match {
          case 1 => DealPlayerCard(seatIndex)
          case 2 => DealCommunityCard(seatIndex)
          case 3 => EnterNextPhase
          case 4 =>
            val chipAmount = jso("amount").flatMap(_.asNumber.flatMap(_.toInt))
            SubtractChips(seatIndex, chipAmount.getOrElse(0))
          case 6 =>
            TransferActionEvent.decoder
              .decodeJson(rawJson)
              .getOrElse(UnknownEvent(-6, rawJson))
          case 8 =>
            deriveDecoder[DealerRake]
              .decodeJson(rawJson)
              .getOrElse(DealerRake(-1))
          case 9       => PlayerAction.interpret(rawJson)
          case 25      => ShowHand(seatIndex)
          case default => UnknownEvent(eventType, rawJson)
        }
      }
      .getOrElse(UnknownEvent(0, rawJson))
  }

  implicit val encoder: Encoder[GameStateEvent] =
    (gameStateEvent: GameStateEvent) => {
      gameStateEvent.encoded
    }
}
