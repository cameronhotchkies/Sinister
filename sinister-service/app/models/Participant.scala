package models

import io.circe.{Encoder, Json}

import scala.util.hashing.MurmurHash3

case class Participant(
    name: String,
    handsPlayed: Int
) {
  val hash: String = {
    val fwHash = MurmurHash3.stringHash(name)
    val bwHash = MurmurHash3.stringHash(name.reverse)

    f"$fwHash%08x$bwHash%08x"
  }
}
object Participant {
  implicit val encoder: Encoder[Participant] = participant => {
    Json.obj(
      "name" -> Json.fromString(participant.name),
      "handsPlayed" -> Json.fromInt(participant.handsPlayed),
      "hash" -> Json.fromString(participant.hash)
    )
  }
}
