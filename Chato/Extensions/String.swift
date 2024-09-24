import Foundation

extension String {
  var isMeaningful: Bool {
    !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var isMeaningless: Bool {
    self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var meaningfulString: String {
    self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var isBestModel: Bool {
    self.contains("gpt-4") && self != "gpt-4o-mini"
  }

  var containsEmoji: Bool {
    return self.unicodeScalars.contains { $0.properties.isEmoji }
  }
}

extension Unicode.Scalar.Properties {
  /// A more precise definition of what is considered an emoji,
  /// accounting for the latest emojis and various modifiers.
  var isEmoji: Bool {
    // Basic Emoji property check
    if self.isEmojiPresentation {
      return true
    }

    // Text presentation sequence for emoji with skin tones and other modifiers
    let isModifiedEmoji = self.generalCategory == .otherSymbol && !self.isASCIIHexDigit
    return isModifiedEmoji || self.isEmojiModifierBase
  }
}
