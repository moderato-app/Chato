import SwiftData
import SwiftUI
import SystemNotification

struct ContentView: View {
  @StateObject private var storeVM = StoreVM()
  @StateObject private var pref = Pref.shared
  @StateObject private var notificationContext = SystemNotificationContext()

  var body: some View {
    GeometryReader { geometry in
      HomePage()
        .environmentObject(EM.shared)
        .environmentObject(storeVM)
        .environmentObject(pref)
        .environmentObject(notificationContext)
        .preferredColorScheme(pref.computedColorScheme)
        .environment(\.screenSize, geometry.size)
    }
    .systemNotification(notificationContext)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
