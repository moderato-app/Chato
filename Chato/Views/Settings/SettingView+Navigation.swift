import SwiftUI

extension SettingView {
  @ViewBuilder
  var dangerZoneLink: some View {
    NavigationLink {
      DangerZoneView()
    } label: {
      Label {
        Text("Danger Zone")
      } icon: {
        Image(systemName: "exclamationmark.circle")
          .foregroundColor(.pink)
      }
    }
  }
  
  @ViewBuilder
  var debugZoneLink: some View {
    NavigationLink {
      DebugZoneView()
    } label: {
      Label {
        Text("Debug")
      } icon: {
        Image(systemName: "ladybug.circle")
          .foregroundColor(.teal)
      }
    }
  }
}

