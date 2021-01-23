package models.gamestate.playeraction

import io.circe.Json
import models.gamestate.{AppliesToPlayer, GameNarrative, GameStateEvent}

trait PlayerAction
    extends GameStateEvent
    with GameNarrative
    with AppliesToPlayer

object PlayerAction {

  private val FOLD = Some(1)
  private val CHECK = Some(2)
  private val CALL = Some(3)
  private val SMALL_BLIND = Some(6)
  private val BIG_BLIND = Some(7)
  private val BET = Some(8)
  private val RAISE = Some(9)
  private val SHOW_CARDS = Some(10)
  private val MUCK_CARDS = Some(11)
  private val DO_NOT_SHOW_CARDS = Some(16)
  private val FIRST_TO_ACT = Some(26)

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
              Check(seatIndex)
            case (CALL, Some(seatIndex), Some(amount)) =>
              Call(seatIndex, amount)
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
            case (MUCK_CARDS, Some(seatIndex), _) =>
              MuckCards(seatIndex)
            case (DO_NOT_SHOW_CARDS, Some(seatIndex), _) =>
              DoNotShowCards(seatIndex)
            case (FIRST_TO_ACT, Some(seatIndex), _) =>
              FirstToAct(seatIndex)
            case (Some(actionType), _, _) =>
              UnknownPlayerAction(actionType, rawJson)
          }

        playerAction
      })
      .getOrElse(UnknownPlayerAction(-89, rawJson))
  }
}
