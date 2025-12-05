import SwiftData
import SwiftUI

struct ContextLengthView: View {
  let inputText: String?
  let outputText: String?

  init(_ inputContextLength: Int? = nil, _ outputContextLength: Int? = nil) {
    self.inputText = inputContextLength.map { formatContextLength($0) }
    self.outputText = outputContextLength.map { formatContextLength($0) }
  }

  var body: some View {
    if let input = inputText, let output = outputText {
      Text("IO: \(input) / \(output)")
        .font(.caption)
        .foregroundColor(.secondary)
    } else if let input = inputText {
      Text("IN: \(input)")
        .font(.caption)
        .foregroundColor(.secondary)
    } else if let output = outputText {
      Text("OUT: \(output)")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
}
