import StoreKit
import SwiftUI

struct VersionView: View {
  var body: some View {
    HStack {
      Label {
        Text("Version")
          .tint(.primary)
      } icon: {
        Image(systemName: "v.circle")
      }
      .contextMenu {
        Button(action: {
          #if os(iOS)
            UIPasteboard.general.string = targetText()
          #elseif os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(targetText, forType: .string)
          #endif
        }) {
          Text("Copy")
        }
      }
      Spacer()
      Text("\(getAppVersion())")
        .foregroundStyle(.secondary)
    }
  }

  private func targetText() -> String {
    return getAppVersion()
  }
}

#Preview {
  VersionView()
}
