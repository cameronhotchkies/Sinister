package actors

import actors.PlayerRegistry.{PlayerSeen, RecentPlayers, TimerKey}
import akka.actor.{Actor, Props, Timers}
import play.api.Logger

import java.time.Instant
import java.time.temporal.ChronoUnit
import scala.concurrent.duration.DurationInt
import scala.language.postfixOps

case class TtlCheck(highWaterMark: Instant)

class PlayerRegistry extends Actor with Timers {

  def receive: Receive = active(Map.empty)

  override def preStart(): Unit = {
    scheduleTtlCheck()
  }

  val logger: Logger = Logger("application")

  def active(registry: Map[String, Instant]): Receive = {
    case TtlCheck(highWaterMark) => expirePlayers(registry, highWaterMark)
    case RecentPlayers           => {
      logger.info("RP")
      sender() ! registry.keys.toSeq
    }
    case PlayerSeen(playerSeen)  => registerPlayerSeen(registry, playerSeen)
  }

  def registerPlayerSeen(
      registry: Map[String, Instant],
      player: String
  ): Unit = {
    val newRegistry = registry.updated(player, Instant.now())
    context become active(newRegistry)
  }

  def scheduleTtlCheck(): Unit = {
    val ttl = TtlCheck(Instant.now().minus(15, ChronoUnit.MINUTES))
    timers.startTimerWithFixedDelay(TimerKey, ttl, 1 minute)
  }

  def expirePlayers(
      registry: Map[String, Instant],
      highWaterMark: Instant
  ): Unit = {
    val updatedRegistry = registry.filter {
      case (_, lastSeen) => lastSeen.isAfter(highWaterMark)
    }

    val registryDelta = registry.size -updatedRegistry.size
    if (registryDelta > 0) {
      logger.info(s"expiring $registryDelta players from $highWaterMark")
    }

    scheduleTtlCheck()
    context become active(updatedRegistry)
  }
}

object PlayerRegistry {
  val props: Props = Props[PlayerRegistry]()

  private case object TimerKey

  case class PlayerSeen(player: String)

  case object RecentPlayers {}
}
