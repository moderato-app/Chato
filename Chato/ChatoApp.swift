import SwiftData
import SwiftUI
import TipKit

@main
struct ChatoApp: App {
  init() {
    do {
      try Tips.configure()
    } catch {
      print("failed to try? Tips.configure(): \(error)")
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
