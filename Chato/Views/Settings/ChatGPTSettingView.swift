import SwiftUI

import Haptico
import SwiftData
import SwiftUI

struct ChatGPTSettingView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      Form {
        ChatGPTSettingSection()
      }
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }.foregroundColor(.accentColor)
        }
      }
      .navigationTitle("ChatGPT Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview("SettingView") {
  LovelyPreview {
    ChatGPTSettingView()
  }
}
