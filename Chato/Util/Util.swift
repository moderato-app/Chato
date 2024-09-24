import Foundation

enum EnvType {
  case testFlight, debug, product
}

var currentEnvType: EnvType {
  if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
    return .debug
  }
  #if DEBUG
    return .debug
  #else
    return .product
  #endif
}

func formatAgo(from date: Date) -> String {
  let now = Date()
  let calendar = Calendar.current
  let delta = abs(now.timeIntervalSince(date))

  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .full
  let d = whichDay(date)

  if delta < 60 {
    return "Now"
  } else if delta < 60 * 60 {
    let minutes = Int(delta / 60)
    return "\(minutes)min"
  } else if delta < 24 * 60 * 60 {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  } else if calendar.isDate(now, equalTo: date, toGranularity: .month) {
    let formatter = DateFormatter()
    formatter.dateFormat = "\(d), HH:mm"
    return formatter.string(from: date)
  } else if calendar.isDate(now, equalTo: date, toGranularity: .year) {
    let formatter = DateFormatter()
    formatter.dateFormat = "\(d) MMM, HH:mm"
    return formatter.string(from: date)
  } else {
    let formatter = DateFormatter()
    formatter.dateFormat = "\(d) MMM yyyy, HH:mm"
    return formatter.string(from: date)
  }
}

func whichDay(_ date: Date) -> String {
  if Locale.current.identifier.hasPrefix("en_") {
    let day = Calendar.current.component(.day, from: date)
    let daySuffix: String
    switch day {
    case 1, 21, 31:
      daySuffix = "st"
    case 2, 22:
      daySuffix = "nd"
    case 3, 23:
      daySuffix = "rd"
    default:
      daySuffix = "th"
    }
    return "d'\(daySuffix)'"
  } else {
    return "d"
  }
}

func getAppVersion() -> String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
        return "\(version).\(build)"
    }
    return ""
}
