import SwiftUI

struct EnvTypeView: View {
  var body: some View {
    if currentEnvType == .product {
      EmptyView()
    } else {
      VStack {
        HStack {
          switch currentEnvType{
          case .debug:
            HStack(spacing: 2) {
              Image(systemName: "ant")
              Text("Debug")
            }
          case .testFlight:
            HStack(spacing: 2) {
              Image(systemName: "fanblades")
                .font(.caption2)
              Text("TestFlight")
            }
            .foregroundColor(.blue)
          case .product:
            EmptyView()
          }
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.clear.background(.ultraThinMaterial))
        .clipShape(.capsule)
        .allowsHitTesting(false)
      }
    }
  }
}

#Preview {
  EnvTypeView()
}
