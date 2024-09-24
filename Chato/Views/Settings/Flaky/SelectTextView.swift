import SwiftUI

struct SelectTextView: View {
  @Environment(\.dismiss) var dismiss
  private var text: String

  init(_ text: String) {
    self.text = text
  }

  var body: some View {
    NavigationStack {
      VStack {
        SelectableTextEditor(text)
        Spacer()
      }
      .padding(.horizontal)
      .navigationTitle("Select Text")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button("", systemImage: "xmark.circle.fill") {
          dismiss()
        }
        .tint(.secondary.opacity(0.8))
      }
    }
  }
}

struct SelectableTextEditor: UIViewRepresentable {
  var text: String

  init(_ text: String) {
    self.text = text
  }

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.font = UIFont.preferredFont(forTextStyle: .body)

    textView.isEditable = false

    textView.isUserInteractionEnabled = true
    textView.isSelectable = true
    textView.dataDetectorTypes = .all

    textView.backgroundColor = .clear
    textView.text = text
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
    uiView.selectAll(nil)
  }
}

#Preview {
  SelectTextView(String(repeating: "M", count: 200))
    .font(.body)
}
