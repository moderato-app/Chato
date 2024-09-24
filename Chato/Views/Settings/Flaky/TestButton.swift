import Haptico
import SwiftData
import SwiftUI

struct TestButton: View {
  var action: () async -> ActionState
  @State private var state: ActionState = .none
  @State private var runningTask: Task<Void, Never>? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: state == .none ? 0 : 10) {
      HStack {
        Button("Test", systemImage: "goforward") {
          withAnimation(.spring) {
            state = .inProgress
          }
          runningTask = Task {
            let r = await action()
            DispatchQueue.main.async {
              withAnimation(.bouncy) {
                state = r
              }
            }
          }
        }
        .disabled(state == .inProgress)
        .foregroundColor(state == .inProgress ? .secondary : .accentColor)
        Spacer()
        switch state {
        case .none, .inProgress:
          EmptyView()
        case .succeeded:
          Text("Good! 😀").foregroundColor(.green)
        case .failed:
          Text("Bad! ☹️").foregroundColor(.orange)
        }
      }
      VStack(alignment: .leading) {
        switch state {
        case .none:
          EmptyView()
        case .inProgress:
          Text("You: Hello!")
          HStack {
            Text("ChatGPT:  ")
            ProgressView()
          }
        case .succeeded(let result):
          Text("You: Hello!")
          Text("ChatGPT: \(result)")
        case .failed(let result):
          Text("You: Hello!")
          Text("ChatGPT: \(result)")
        }
      }.font(.footnote)
    }
    .onDisappear {
      runningTask?.cancel()
      runningTask = nil
    }
  }
}

public enum ActionState: Equatable {
  case none, inProgress, succeeded(String), failed(String)
}

#Preview {
  Form {
    TestButton(action: succeedAction)
    TestButton(action: failAction)
  }
}

private func succeedAction() async -> ActionState {
  try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
  return .succeeded("OK")
}

private func failAction() async -> ActionState {
  try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
  return .failed("Network error \n abcd asdf asdf")
}
