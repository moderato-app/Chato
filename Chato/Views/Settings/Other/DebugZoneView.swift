import SwiftUI

struct DebugZoneView: View {
  @EnvironmentObject var pref: Pref

  var body: some View {
    List {
      Section("") {
        Button("Reset User Defauts", systemImage: "arrow.clockwise") {
          pref.reset()
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
