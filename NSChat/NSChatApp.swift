import SwiftData
import SwiftUI
import TipKit
import os

public let bundleName = Bundle.main.bundleIdentifier ?? "app.moderato.Chato.Chato"

@main
struct NSChat: App {
  init() {
    do {
      try Tips.configure()
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Configure Tips",
        component: "NSChat",
        userMessage: nil
      ))
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(ModelContainer.product())
    #if os(macOS)
      .commands {
        SidebarCommands()
      }
    #endif
  }
}
