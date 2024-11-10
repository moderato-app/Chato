import SwiftData
import SwiftUI

struct ContentView: View {
  @State private var navigationContext = NavigationContext()
  @StateObject var storeVM = StoreVM()
  @ObservedObject var pref = Pref.shared
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HomePage()
      .environment(navigationContext)
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
