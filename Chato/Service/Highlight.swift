// Created for Chato in 2024

import Foundation
import Highlightr
import MarkdownUI
import SwiftUI

struct HI: CodeSyntaxHighlighter {
  func highlightCode(_ code: String, language: String?) -> Text {
    if let highlightedCode = Self.shared.highlightr.highlight(code, as: language) {
      return convertToText(highlightedCode)
    } else {
      return Text("")
    }
  }

  static var shared = HI()
  private let highlightr: Highlightr

  private init() {
    self.highlightr = Highlightr()!
    if !highlightr.setTheme(to: "panda-syntax-dark") {
      print("failed to load panda-syntax-dark.min.css")
    }
  }
}

private func convertToText(_ attributedString: NSAttributedString) -> Text {
  var result = Text("") // Start with an empty Text
  attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { attributes, range, _ in
    // Create a substring for the given range
    let substring = attributedString.attributedSubstring(from: range).string

    // Create a Text view with attributes applied
    var text = Text(substring)

    // Apply attributes to the Text
    text = text.font(.callout) // Change font to SwiftUI Font
//    if let font = attributes[.font] as? UIFont {
//      text = text.font(.system(size: font.pointSize)) // Change font to SwiftUI Font
//    }
    if let color = attributes[.foregroundColor] as? UIColor {
      text = text.foregroundColor(Color(color)) // Change color to SwiftUI Color
    }
    // Add more attributes as needed (e.g. underline, strikethrough, etc.)

    // Combine the attributed Text fragments
    result = result + text
  }

  return result.fontDesign(.monospaced)
}
