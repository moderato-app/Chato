import Foundation

extension Bool: @retroactive Comparable {
  public static func <(lhs: Self, rhs: Self) -> Bool {
    !lhs && rhs
  }
}

func sleepFor(_ second: Double = 1) async {
  // Sleep for 1 second
  try? await Task.sleep(nanoseconds: UInt64(Double(1_000_000_000) * second))
  // Continue execution here
}
