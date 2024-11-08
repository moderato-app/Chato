import SwiftData
import TipKit
import SwiftUI

@main
struct ChatoApp: App {
  
  init(){
    try? Tips.configure()
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
