import Haptico
import SwiftData
import SwiftUI

struct TestButton: View {
  var action: () async -> ActionState
  @State private var state: ActionState = .none
  @State private var runningTask: Task<Void, Never>? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Button("Test") {
        state = .inProgress
        runningTask = Task {
          let r = await action()
          Task { @MainActor in
            state = r
          }
        }
      }
      .disabled(state == .inProgress)
      .foregroundStyle(.tint)

      switch state {
      case .none:
        EmptyView()
      case .inProgress, .succeeded, .failed:
        VStack(alignment: .leading) {
          Text("You: Hello!").foregroundStyle(.secondary)

          Group { Text("ChatGPT: ").foregroundStyle(.secondary) + Text(textContent).foregroundStyle(textColor) }
            .overlay(alignment: .trailing) {
              if state == .inProgress {
                ProgressView().scaleEffect(0.8).offset(x: 20)
              }
            }
        }
      }
    }
    .onDisappear {
      runningTask?.cancel()
      runningTask = nil
    }
    .animation(.easeInOut, value: state)
  }

  var textContent: String {
    switch state {
    case .succeeded(let result), .failed(let result):
      result
    default:
      ""
    }
  }

  var textColor: Color {
    switch state {
    case .failed:
      Color.orange
    default:
      Color.secondary
    }
  }
}

public enum ActionState: Equatable {
  case none, inProgress, succeeded(String), failed(String)
}

#Preview {
  Form {
    TestButton(action: succeedAction)
    VStack(alignment: .leading) {
      TestButton(action: failAction)
      Text("You: Hello!")
      HStack {
        Text("ChatGPT:  ")
        Text(" ").overlay { ProgressView().scaleEffect(0.8) }
      }
    }
    VStack(alignment: .leading) {
      TestButton(action: failAction)
      Text("You: Hello!")
      HStack {
        Text("ChatGPT:  xxx")
      }
    }
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
