import org.scalatest.enablers.{Definition, Emptiness}

package object scaffolding {
  // Stronger option implicits for scalatest
  implicit def emptinessOfOption[e]: Emptiness[Option[e]] =
    (opt: Option[e]) => opt.isEmpty

  implicit def definitionOfOption[e]: Definition[Option[e]] =
    (opt: Option[e]) => opt.isDefined
}
