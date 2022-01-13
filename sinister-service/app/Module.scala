
import actors.{GamestateCollector, HandLogMonitor, PlayerRegistry, TableRegistry}
import com.google.inject.AbstractModule
import play.api.libs.concurrent.AkkaGuiceSupport

class Module extends AbstractModule with AkkaGuiceSupport {

  override def configure = {
    bindActor[HandLogMonitor]("hand-log-monitor")
    bindActor[GamestateCollector]("gamestate-collector")
    bindActor[TableRegistry](name="table-registry")
    bindActor[PlayerRegistry](name="player-registry")
  }
}
