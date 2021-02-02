package actors

import actors.TableRegistry.{AddTables, TableById}
import akka.actor.{Actor, Props}
import models.Table
import play.api.Logger

class TableRegistry extends Actor {

  private val logger = Logger("application")

  def receive: Receive = active(Map.empty)

  def active(registry: Map[Int, Table]): Receive = {

    case AddTables(tables) =>
      val newKeyVals = tables.map { t =>
        t.id -> t
      }
      val newRegistry = registry ++ newKeyVals
      context become active(newRegistry)

    case TableById(tableId) =>
      sender() ! registry.get(tableId)
  }
}

object TableRegistry {
  val props: Props = Props[TableRegistry]()

  case class TableById(tableId: Int)
  case class AddTables(tables: Seq[Table])
}
