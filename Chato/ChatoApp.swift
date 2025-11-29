import SwiftData
import SwiftUI
import TipKit
import os

@main
struct ChatoApp: App {
  init() {
    do {
      try Tips.configure()
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Configure Tips",
        component: "ChatoApp",
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
