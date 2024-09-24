import SwiftUI

struct SendingView: View {
  @State private var rotation: Double = 0

  var body: some View {
    Image(systemName: "circle.dotted")
      .fontWeight(.black)
      .rotationEffect(Angle.degrees(rotation))
      .onAppear {
        withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
              rotation = 360
          }
      }
  }
}

#Preview {
  SendingView().background(.secondary)
}
