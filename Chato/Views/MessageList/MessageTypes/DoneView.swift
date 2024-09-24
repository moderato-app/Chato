import SwiftUI

struct DoneView: View {
  var body: some View {
    Image(systemName: "checkmark.circle.fill")
      .symbolRenderingMode(.monochrome)
      .symbolVariant(.none)
      .fontWeight(.regular)
      .symbolEffect(.scale)
  }
}

#Preview {
  DoneView()
}
