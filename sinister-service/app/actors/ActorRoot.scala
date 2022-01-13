package actors

import akka.actor.{ActorRef, ActorSystem}
import play.api.mvc.{AbstractController, ControllerComponents}

import javax.inject.{Inject, Named, Singleton}

@Singleton
class ActorRoot @Inject() (
    system: ActorSystem,
    cc: ControllerComponents,
    @Named("hand-log-monitor") val handLogMonitor: ActorRef,
    @Named("gamestate-collector") val sinkCache: ActorRef,
    @Named("table-registry") val tableRegistry: ActorRef,
    @Named("player-registry") val playerRegistry: ActorRef
) extends AbstractController(cc) {
}
