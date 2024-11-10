import SwiftUI

struct DoneStatusView: View {
  var body: some View {
    Image(systemName: "checkmark.circle.fill")
      .symbolRenderingMode(.monochrome)
      .symbolVariant(.none)
      .fontWeight(.regular)
      .symbolEffect(.scale)
  }
}

#Preview {
  DoneStatusView()
}
