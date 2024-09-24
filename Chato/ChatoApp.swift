import SwiftData
import SwiftUI

@main
struct ChatoApp: App {
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
