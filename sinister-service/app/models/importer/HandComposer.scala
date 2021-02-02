package models.importer

import actors.ActorRoot
import actors.TableRegistry.TableById
import akka.pattern.ask
import akka.util.Timeout
import models.{Hand, Table}

import javax.inject.{Inject, Singleton}
import scala.concurrent.duration.DurationInt
import scala.concurrent.{ExecutionContext, Future}
import scala.language.postfixOps

@Singleton
class HandComposer @Inject() (
    val actorRoot: ActorRoot,
    implicit val ec: ExecutionContext
) {

  def tableById(tableId: Int): Future[Option[Table]] = {
    implicit val timeout: Timeout = 300 millis
    val tableResponse = actorRoot.tableRegistry ? TableById(tableId)

    val filteredResponse = tableResponse.collect {
      case Some(t: Table) => Option(t)
      case None => None
      case _ => None
    }

    filteredResponse
  }

  def composeHand(): Hand = {
    // This will pull in the summary logic eventually
    ???
  }
}
