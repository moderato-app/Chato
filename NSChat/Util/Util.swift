import Foundation

func formatAgo(from date: Date) -> String {
  let formatter = RelativeDateTimeFormatter()
  formatter.unitsStyle = .abbreviated
  formatter.locale = Locale.current
  return formatter.localizedString(for: date, relativeTo: Date())
}

func getAppVersion() -> String {
  if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
     let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
  {
    return "\(version).\(build)"
  }
  return ""
}
