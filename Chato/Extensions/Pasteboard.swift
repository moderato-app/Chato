// Created for GPTLite in 2024
#if canImport(UIKit)
import UIKit

func copy(_ str: String) {
  UIPasteboard.general.string = str
}

#elseif canImport(AppKit)
import AppKit

func copy(_ str: String) {
  let pasteboard = NSPasteboard.general
  pasteboard.clearContents()
  pasteboard.setString(str, forType: .string)
}
#endif
