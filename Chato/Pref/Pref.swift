import SwiftData
import SwiftUI

class Pref: ObservableObject {
  static var shared = Pref()

  @AppStorage("wallpaperIndex") var wallpaperIndex = 1
  @AppStorage("haptics") var haptics: Bool = true
  @AppStorage("doubleTapAction") var doubleTapAction: DoubleTapAction = .reuse
  @AppStorage("magicScrolling") var magicScrolling: Bool = true

  @AppStorage("colorScheme") var colorScheme: AppColorScheme = .system

  // ChatGPT
  @AppStorage("gptApiKey") var gptApiKey: String = ""
  @AppStorage("gptUseProxy") var gptUseProxy: Bool = false
  @AppStorage("gptProxyHost") var gptProxyHost: String = ""

  // ChatGPT last used option
  @AppStorage("lastUsedModel") var lastUsedModel: String?
  @AppStorage("lastUsedContextLength") var lastUsedContextLength: Int?
  @AppStorage("lastUsedPromptId") var lastUsedPromptId: String?

  // Fill data record
  @AppStorage("fillDataRecordGreeting") var fillDataRecordGreeting: Bool = false
  @AppStorage("fillDataRecordPrompts") var fillDataRecordPrompts: Bool = false

  var wallpaperName: String? {
    if self.wallpaperIndex == 0 {
      return nil
    }
    return wallpaperImageNames[self.wallpaperIndex - 1]
  }

  var wallpaperDispaleyName: String {
    if self.wallpaperIndex == 0 {
      return "Default"
    }
    return wallpaperImageNames[self.wallpaperIndex - 1].split(separator: "-").first!.capitalized
  }

  func reset() {
    let newPref = Pref()
    self.wallpaperIndex = newPref.wallpaperIndex
    self.haptics = newPref.haptics
    self.doubleTapAction = newPref.doubleTapAction
    self.magicScrolling = newPref.magicScrolling
    self.colorScheme = newPref.colorScheme
    self.gptApiKey = newPref.gptApiKey
    self.gptUseProxy = newPref.gptUseProxy
    self.gptProxyHost = newPref.gptProxyHost
    self.lastUsedModel = newPref.lastUsedModel
    self.lastUsedContextLength = newPref.lastUsedContextLength
    self.lastUsedPromptId = newPref.lastUsedPromptId
    self.fillDataRecordGreeting = newPref.fillDataRecordGreeting
    self.fillDataRecordPrompts = newPref.fillDataRecordPrompts
  }
}

enum DoubleTapAction: String, CaseIterable, Codable {
  case none = "None", reuse = "Reuse Text", copy = "Copy Text"
}

extension Pref {
  enum AppColorScheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
  }

  var computedColorScheme: ColorScheme? {
    switch self.colorScheme {
    case .light:
      return ColorScheme.light
    case .dark:
      return ColorScheme.dark
    case .system:
      return nil
    }
  }
}
