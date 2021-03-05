package actors

import akka.actor.{ActorRef, ActorSystem}
import play.api.mvc.{AbstractController, ControllerComponents}

import javax.inject.{Inject, Named, Singleton}

@Singleton
class ActorRoot @Inject() (
    system: ActorSystem,
    cc: ControllerComponents,
    @Named("hand-log-monitor") val handLogMonitor: ActorRef
) extends AbstractController(cc) {
  val tableRegistry: ActorRef =
    system.actorOf(TableRegistry.props, "table-registry")
  val playerRegistry: ActorRef =
    system.actorOf(PlayerRegistry.props, "player-registry")
}
