package models.importer

import io.circe.Decoder
import models.Card
import models.GameStateAddition.{Flop, PreFlop, River, Turn}
import models.gamestate.{BettingRound, HandEvent, Preflop}
import models.gamestate.HandEvent._
import play.api.Logger

trait GameStateEvent {}

object GameStateEvent {

  implicit val decoder: Decoder[GameStateEvent] = for {
    eventType <- Decoder[Int].prepare(_.downField("type"))
    value <- eventType match {
      case DEAL_PLAYER               => EventDecoders.dealPlayerCard
      case DEAL_COMMUNITY            => EventDecoders.dealCommunityCard
      case BETTING_COMPLETED         => EventDecoders.bettingEnds
      case SUBTRACT_CHIPS_FROM_STACK => EventDecoders.subtractChipsFromStack
      case TRANSFER_BUTTON           => EventDecoders.transferButton
      case HandEvent.TRANSFER_ACTION => EventDecoders.transferAction
      case SUBTRACT_CHIPS_FROM_POT   => EventDecoders.subtractChipsFromPot

      case DEALER_RAKE   => EventDecoders.dealerRake
      case PLAYER_ACTION => PlayerActionDecoders.importDecoder
      case WIN_HAND      => EventDecoders.winHand
      case WIN_POT       => EventDecoders.winPot
      case TABLE_MESSAGE => EventDecoders.tableMessage
      case SHOW_HAND     => EventDecoders.showHand
      case _             => EventDecoders.unknownEvent
    }
  } yield value

  val logger: Logger = Logger("application")

  implicit def toHandEvent(gameStateEvent: GameStateEvent): HandEvent = {
    gameStateEvent match {
      case handEvent: HandEvent => handEvent
      case h =>
        logger.debug(s"HAND EVENT: ${h.getClass}")
        ???
    }
  }

  def communityForRound(stage: Int): Int = {
    if (stage == 2) { 3 }
    else if (stage == 3 || stage == 4) { 1 }
    else { 0 }
  }

  def bettingRoundFor(roundId: Int, cards: Seq[Card]): BettingRound = {
    roundId match {
      case PreFlop => Preflop
      case Flop =>
        models.gamestate.Flop(cards.takeRight(communityForRound(roundId)))
      case Turn =>
        models.gamestate.Turn(cards.takeRight(communityForRound(roundId)))
      case River =>
        models.gamestate.River(cards.takeRight(communityForRound(roundId)))
    }
  }
}
