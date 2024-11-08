import SwiftUI
import TipKit

struct DebugZoneView: View {
  @EnvironmentObject var pref: Pref

  var body: some View {
    List {
      Section("") {
        Button("Reset User Defauts", systemImage: "arrow.clockwise") {
          pref.reset()
        }
        Button("Reset Tips", systemImage: "arrow.clockwise") {
          try? Tips.resetDatastore()
          try? Tips.configure()
        }
      }
    }
    .navigationTitle("Debug Zone")
  }
}

#Preview {
  NavigationStack {
    DebugZoneView()
  }
}
