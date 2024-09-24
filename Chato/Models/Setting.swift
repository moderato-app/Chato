import SwiftData
import SwiftUI

@Model
final class AppStateModel {
  @Attribute(originalName: "colorScheme") var colorScheme: AppColorScheme
  @Relationship(deleteRule: .cascade, originalName: "chatGPTConfig")
  var chatGPTConfig: ChatGPTConfig
  @Relationship(deleteRule: .cascade, originalName: "lastUsedOption")
  var lastUsedOption: ChatOption?
  @Relationship(deleteRule: .cascade, originalName: "dataRecord")
  var dataRecord: DataRecord?

  init() {
    self.colorScheme = .system
    self.chatGPTConfig = ChatGPTConfig()
    self.dataRecord = DataRecord()
  }
}

@Model
final class ChatGPTConfig {
  @Attribute(originalName: "colorScheme") var apiKey: String
  @Attribute(originalName: "userProxy") var userProxy: Bool
  @Attribute(originalName: "proxyHost") var proxyHost: String

  init(_ apiKey: String = "") {
    self.apiKey = apiKey
    self.userProxy = false
    self.proxyHost = ""
  }
}

@Model
final class Functionality {
  @Attribute(originalName: "haptics") var haptics: Bool
  @Attribute(originalName: "doubleTapAction") var doubleTapAction: DoubleTapAction

  init() {
    self.haptics = true
    self.doubleTapAction = .reuse
  }
}

@Model
final class DataRecord {
  @Attribute(originalName: "greeting") var greeting: Bool = false
  @Attribute(originalName: "prompts") var prompts: Bool = false
  init() {}
}

extension AppStateModel: Hashable {
  enum AppColorScheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
  }

  @Transient
  var computedColorScheme: ColorScheme? {
    switch colorScheme {
    case .light:
      return ColorScheme.light
    case .dark:
      return ColorScheme.dark
    case .system:
      return nil
    }
  }
}

extension Functionality {
  enum DoubleTapAction: String, CaseIterable, Codable {
    case none = "None", reuse = "Reuse Text", copy = "Copy Text"
  }
}
