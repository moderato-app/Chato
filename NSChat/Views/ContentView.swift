import SwiftData
import SwiftUI
import SystemNotification

struct ContentView: View {
  @StateObject private var storeVM = StoreVM()
  @StateObject private var pref = Pref.shared

  var body: some View {
    HomePage()
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(pref)
      .preferredColorScheme(pref.computedColorScheme)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
