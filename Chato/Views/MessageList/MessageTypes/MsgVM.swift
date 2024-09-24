import MarkdownUI
import Splash
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
      Color(Self.theme.backgroundColor)
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .markdownMargin(top: .zero, bottom: .em(0.8))
  }
}

#Preview("") {
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
    .markdownCodeSyntaxHighlighter(.splash(theme: pandalong()))
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
    Color(pandalong().backgroundColor)
  }
  .clipShape(RoundedRectangle(cornerRadius: 8))
  .markdownMargin(top: .zero, bottom: .em(0.8))
}

func pandalong() -> Splash.Theme {
  return Splash.Theme(
    font: .init(size: 16),
    plainTextColor: Splash.Color(
      red: 0.902, green: 0.902, blue: 0.902, alpha: 1
    ),
    tokenColors: [
      .keyword: Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .string: Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .type: Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .call: Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .number: Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .comment: Splash.Color(red: 0.733, green: 0.733, blue: 0.733, alpha: 1),
      .property: Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .dotAccess: Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .preprocessing: Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("meta"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("operator"): Splash.Color(red: 0.691, green: 0.518, blue: 0.922, alpha: 1),
      .custom("variable"): Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .custom("attr"): Splash.Color(red: 0.902, green: 0.902, blue: 0.902, alpha: 1),
      .custom("punctuation"): Splash.Color(red: 0.902, green: 0.902, blue: 0.902, alpha: 1),
      .custom("metaKeyword"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("name"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("selectorTag"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("charEscape"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("deletion"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("bultIn"): Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .custom("doctag"): Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .custom("link"): Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .custom("literal"): Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .custom("regexp"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("selectorAttr"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("selectorPseudo"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .custom("titleClass"): Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .custom("titleFunction"): Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .custom("titleClassInherited"): Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .custom("variableLanguage"): Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1)
    ],
    backgroundColor: Splash.Color(
      red: 0.165, green: 0.173, blue: 0.173, alpha: 1
    )
  )
}

func panda(withFont font: Splash.Font) -> Splash.Theme {
  return Splash.Theme(
    font: font,
    plainTextColor: Splash.Color(
      red: 0.902, green: 0.902, blue: 0.902, alpha: 1
    ),
    tokenColors: [
      .keyword: Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1),
      .string: Splash.Color(red: 0.098, green: 0.976, blue: 0.847, alpha: 1),
      .type: Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .call: Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .number: Splash.Color(red: 1.0, green: 0.718, blue: 0.424, alpha: 1),
      .comment: Splash.Color(red: 0.733, green: 0.733, blue: 0.733, alpha: 1),
      .property: Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .dotAccess: Splash.Color(red: 0.271, green: 0.663, blue: 0.976, alpha: 1),
      .preprocessing: Splash.Color(red: 1.0, green: 0.459, blue: 0.718, alpha: 1)
    ],
    backgroundColor: Splash.Color(
      red: 0.165, green: 0.173, blue: 0.173, alpha: 1
    )
  )
}

func lightTheme(withFont font: Splash.Font) -> Splash.Theme {
  return Splash.Theme(
    font: font,
    plainTextColor: Splash.Color(
      red: 0.0, green: 0.0, blue: 0.0, alpha: 1
    ),
    tokenColors: [
      .keyword: Splash.Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1),
      .string: Splash.Color(red: 0.0, green: 0.5, blue: 0.0, alpha: 1),
      .type: Splash.Color(red: 0.6, green: 0.2, blue: 0.8, alpha: 1),
      .call: Splash.Color(red: 0.8, green: 0.2, blue: 0.2, alpha: 1),
      .number: Splash.Color(red: 1.0, green: 0.5, blue: 0.0, alpha: 1),
      .comment: Splash.Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
      .property: Splash.Color(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
      .dotAccess: Splash.Color(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
      .preprocessing: Splash.Color(red: 0.6, green: 0.4, blue: 0.0, alpha: 1)
    ],
    backgroundColor: Splash.Color(
      red: 1.0, green: 1.0, blue: 1.0, alpha: 1
    )
  )
}
