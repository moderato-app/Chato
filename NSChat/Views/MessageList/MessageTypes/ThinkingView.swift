import SwiftUI

struct ThinkingView: View {
  private let maxDots = 3

  @State private var dotCount = 0
  private let timer = Timer.publish(every: 0.33, on: .main, in: .common).autoconnect()

  var body: some View {
    Image(systemName: "ellipsis", variableValue: Double(dotCount) / 3.0)
      .font(.largeTitle)
      .foregroundStyle(.secondary)
      .tint(.blue)
      .padding(10)
      .modifier(MessageRowModifier(.assistant))
      .background(.background)
      .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
      .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15).inset(by: 1))
      .onAppear {
        dotCount = 1
      }
      .onReceive(timer) { _ in
        dotCount = dotCount < maxDots ? dotCount + 1 : 0
      }
  }
}

#Preview {
  VStack{
    ThinkingView()
      .font(.largeTitle).preferredColorScheme(.light)
    ThinkingView()
      .font(.largeTitle).preferredColorScheme(.dark)
  }
}
