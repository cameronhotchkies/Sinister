package actors

import actors.HandLogMonitor.{Activate, Deactivate, TimerKey}
import akka.actor.{Actor, Props, Timers}
import play.api.Logger

import java.time.Instant
import java.time.temporal.ChronoUnit
import scala.concurrent.duration.DurationInt
import scala.language.postfixOps

case class FilesystemCheck(highWaterMark: Instant)

class HandLogMonitor extends Actor with Timers {
  override def receive: Receive = inactive()

  val logger: Logger = Logger("application")

  def setActive(): Unit = {
    scheduleFileSystemCheck()
  }

  def scheduleFileSystemCheck(): Unit = {
    val ttl = FilesystemCheck(Instant.now().minus(15, ChronoUnit.MINUTES))
    timers.startTimerWithFixedDelay(TimerKey, ttl, 1 minute)
  }

  def inactive(): Receive = {
    case Activate => {
      logger.debug("Activating")
      val fsc = FilesystemCheck(Instant.now())
      timers.startSingleTimer(TimerKey, fsc, 10 seconds)
      context become active()
    }
    case Deactivate => ()
  }

  def active(): Receive = {
    case Deactivate => {
      logger.debug("Deactivating")
      context become inactive()
    }
    case FilesystemCheck(_) => {
      logger.debug("This is where we check the filesystem")
      scanHandLogs
      val fsc = FilesystemCheck(Instant.now())
      timers.startSingleTimer(TimerKey, fsc, 10 seconds)
    }
    case Activate => ()
  }

  def scanHandLogs = {
    val parsedCache = Nil

    logger.debug(s"${parsedCache.length} files could be parsed now")
  }
}

object HandLogMonitor {
  val props: Props = Props[HandLogMonitor]()

  private case object TimerKey

  case object Activate {}
  case object Deactivate {}

  val handSink = "logs/hands"

  val logger: Logger = Logger("application")
}
