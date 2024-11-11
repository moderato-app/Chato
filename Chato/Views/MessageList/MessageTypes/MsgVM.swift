import MarkdownUI
import SwiftUI

extension NormalMsgView {
  @ViewBuilder
  func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Text((configuration.language == nil || configuration.language == "") ? "plain text" : configuration.language!)
          .fontDesign(.monospaced)
          .font(.callout)
          .fontWeight(.semibold)
          .foregroundStyle(Color(red: 0.098, green: 0.976, blue: 0.847))
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background(Color.black.opacity(0.3).background(.ultraThinMaterial))
          .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous))
      }

      ScrollView(.horizontal) {
        configuration.label
          .relativeLineSpacing(.em(0.25))
          .markdownTextStyle {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
          }
          .padding()
      }
    }
    .background {
      Color(Color(red: 0.165, green: 0.173, blue: 0.173))
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .markdownMargin(top: .zero, bottom: .em(0.8))
  }
}

#Preview("1") {
  let c = """
  ```swift
  struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

    init(theme: Splash.Theme) {
      self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text {
      guard language != nil else {
        return Text(content)
      }

      return self.syntaxHighlighter.highlight(content)
    }
  }
  ```
  """

  Markdown(c)
    .textSelection(.enabled)
    .markdownBlockStyle(\.codeBlock) {
      codeBlock2($0)
    }
    .markdownCodeSyntaxHighlighter(HI.shared)
}

@ViewBuilder
func codeBlock2(_ configuration: CodeBlockConfiguration) -> some View {
  VStack(spacing: 0) {
    HStack {
      Spacer()
      Text(configuration.language ?? "plain text")
        .fontDesign(.monospaced)
        .font(.callout)
        .fontWeight(.semibold)
        .foregroundStyle(Color(red: 0.098, green: 0.976, blue: 0.847))
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.black.opacity(0.3).background(.ultraThinMaterial))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .continuous))
    }

    Divider().foregroundStyle(.gray)

    ScrollView(.horizontal) {
      configuration.label
        .relativeLineSpacing(.em(0.25))
        .markdownTextStyle {
          FontFamilyVariant(.monospaced)
          FontSize(.em(0.85))
        }
        .padding()
    }
  }
  .background {
    Color(Color(red: 0.165, green: 0.173, blue: 0.173))
  }
  .clipShape(RoundedRectangle(cornerRadius: 8))
  .markdownMargin(top: .zero, bottom: .em(0.8))
}
