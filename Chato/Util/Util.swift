import Foundation

func formatAgo(from date: Date) -> String {
  let now = Date()
  let calendar = Calendar.current
  let delta = abs(now.timeIntervalSince(date))

  if delta < 60 {
    return "Now"
  } else if delta < 60 * 60 {
    let minutes = Int(delta / 60)
    return "\(minutes) min ago"
  } else if delta < 24 * 60 * 60 {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  } else if calendar.isDate(now, equalTo: date, toGranularity: .weekOfYear) {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, HH:mm"
    return formatter.string(from: date)
  } else if calendar.isDate(now, equalTo: date, toGranularity: .year) {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, HH:mm"
    return formatter.string(from: date)
  } else {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d yyyy, HH:mm"
    return formatter.string(from: date)
  }
}

func getAppVersion() -> String {
  if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
     let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
  {
    return "\(version).\(build)"
  }
  return ""
}
