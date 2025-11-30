import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var storeVM = StoreVM()
  @StateObject private var pref = Pref.shared

  var body: some View {
    GeometryReader { geometry in
      HomePage()
        .environmentObject(EM.shared)
        .environmentObject(storeVM)
        .environmentObject(pref)
        .preferredColorScheme(pref.computedColorScheme)
        .environment(\.screenSize, geometry.size)
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
