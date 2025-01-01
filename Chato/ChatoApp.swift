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
        .onAppear {
          loadInjectionDeviceAndSimulator()
        }
    }
    .modelContainer(ModelContainer.product())
    #if os(macOS)
      .commands {
        SidebarCommands()
      }
    #endif
  }
}

func loadInjectionDeviceAndSimulator() {
  if let path = Bundle.main.path(
    forResource:
    "iOSInjection", ofType: "bundle")
    ?? Bundle.main.path(
      forResource:
      "macOSInjection", ofType: "bundle")
  {
    Bundle(path: path)!.load()
  }
}

func loadInjectionSimulator() {
  #if DEBUG
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
    // for tvOS:
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection.bundle")?.load()
    // Or for macOS:
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
  #endif
}
