package models

case class Boundary(
    min: BigDecimal,
    max: BigDecimal,
    worstHands: List[Hand],
    bestHands: List[Hand]
)

object Boundary {
  val ZERO: Boundary = Boundary(min = Int.MaxValue, max = Int.MinValue, Nil, Nil)
}
