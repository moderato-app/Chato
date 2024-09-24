import SwiftUI

struct TextEditPageVIew: View {
  @Binding var text: String
  var title: String
  var fb: fallbackType = .empty
  @State private var initialText = ""
  @State private var textInField = ""
  var description: String?
  var links: [(String, String)]?
  @FocusState var isFocused: Bool

  var fallbackText: String {
    switch fb {
    case .empty:
      return ""
    case .initial:
      return initialText
    case .fixed(let s):
      return s
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      Form {
        Section(footer: DescriptionAndLinks(description: description, links: links)) {
          ZStack {
            TextField(fallbackText, text: $textInField)
              .focused($isFocused)
              .padding(.trailing, 40)
              .onChange(of: textInField) { _, b in
                if !b.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                  text = textInField
                }
              }
            if !textInField.isEmpty {
              Button {
                textInField = ""
              } label: {
                HStack {
                  Spacer()
                  Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                }
              }
            }
          }
        }.textCase(.none)
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      isFocused = true
      initialText = text
      textInField = text
    }
    .onDisappear {
      let trimmed = textInField.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmed.isEmpty {
        text = fallbackText
      } else {
        text = trimmed
      }
    }
  }

  enum fallbackType {
    case empty, initial, fixed(String)
  }
}

struct DescriptionAndLinks: View {
  var description: String?
  var links: [(String, String)]?

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      if let description = description {
        Text(description)
          .foregroundStyle(.secondary)
      }
      if let safeLinks = links {
        VStack(spacing:15) {
          ForEach(safeLinks, id: \.0) { link in
            if let url = URL(string: link.1) {
              Link(link.0, destination: url).font(.footnote)
                .foregroundColor(.accentColor)
            }
          }
        }
      }
    }
  }
}

struct AddContainer_Previews: PreviewProvider {
  @State static var text = "sk-aaaaaaaaaaaaaaaaaaa33333333333333333333333333"
  static var previews: some View {
    TextEditPageVIew(text: $text, title: "ChatGPT API Key",
                     description: apiKeyExplain,
                     links: apiKeyExplainLlinks)
  }
}
