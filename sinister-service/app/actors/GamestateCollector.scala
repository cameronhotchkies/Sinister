package actors

import akka.actor.{Actor, Props}
import io.circe.Json
import play.api.Logger

case class IntakeGamestate(
                            gameId: Int,
                            gamestateData: Json
                          )

class GamestateCollector extends Actor {
  override def receive: Receive = {
    case IntakeGamestate(gameId, content) => {
      val childName = s"game-${gameId}"

      val target = context
        .child(childName)
        .getOrElse {
          val newChild = context.actorOf(Props[ActiveHand], childName)
          newChild ! ActivateHand(gameId)
          newChild
        }

      target ! RawGamestate(content)
    }
  }
}

class ActiveHand extends Actor {
  val logger: Logger = Logger("application")

  def active(gameId: Int, states: List[Json]): Receive = {
    case RawGamestate(content) => {
      val newStates = states :+ content
      logger.debug(s"Tracking ${newStates.length} states for $gameId")
      context become active(gameId, newStates)
    }
  }

  override def receive: Receive = {
    case ActivateHand(gameId) => {
      logger.debug(s"activating ${gameId}")
      context become active(gameId, Nil)
    }
  }
}

case class ActivateHand(gameId: Int)
case class RawGamestate(value: Json)
