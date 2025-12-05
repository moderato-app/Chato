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

func doubleEqual(_ a: Double, _ b: Double) -> Bool {
  return fabs(a - b) < Double.ulpOfOne
}

func formatContextLength(_ length: Int) -> String {
  if length >= 1_000_000 {
    let millions = Double(length) / 1_000_000.0
    if millions.truncatingRemainder(dividingBy: 1.0) == 0 {
      return "\(Int(millions))M"
    } else {
      return String(format: "%.1fM", millions)
    }
  } else if length >= 1_000 {
    let thousands = Double(length) / 1_000.0
    if thousands.truncatingRemainder(dividingBy: 1.0) == 0 {
      return "\(Int(thousands))K"
    } else {
      return String(format: "%.1fK", thousands)
    }
  } else {
    return "\(length)"
  }
}
