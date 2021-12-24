
import actors.{HandLogMonitor, GamestateCollector}
import com.google.inject.AbstractModule
import play.api.libs.concurrent.AkkaGuiceSupport

class Module extends AbstractModule with AkkaGuiceSupport {

  override def configure = {
    bindActor[HandLogMonitor]("hand-log-monitor")
    bindActor[GamestateCollector]("gamestate-collector")
  }
}
