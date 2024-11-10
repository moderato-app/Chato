import SwiftUI

struct MessageRowModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  private let role: Message.MessageRole

  init(_ role: Message.MessageRole) {
    self.role = role
  }

  var foreColor: Color {
    if colorScheme == .light {
      role == .assistant ? Color(hex: "000000") : Color(hex: "ffffff")
    } else {
      role == .assistant ? Color(hex: "e9e9e9") : Color(hex: "e7ebfc")
    }
  }

  var backColor: Color {
    if colorScheme == .light {
      role == .assistant ? Color(hex: "e9e9e9") : Color(hex: "3f61e6")
    } else {
      role == .assistant ? Color(hex: "3b3b3b") : Color(hex: "3f61e6")
    }
  }

  func body(content: Content) -> some View {
    content
      .foregroundColor(foreColor)
      .background(backColor)
  }
}

struct StatusModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  private let role: Message.MessageRole

  init(_ role: Message.MessageRole) {
    self.role = role
  }

  var foreColor: Color {
    if colorScheme == .light {
      role == .assistant ? Color(hex: "5e5e5e") : Color(hex: "d7ddfa")
    } else {
      role == .assistant ? Color(hex: "b9b9b9") : Color(hex: "d9dffa")
    }
  }

  func body(content: Content) -> some View {
    content
      .foregroundColor(foreColor)
  }
}

struct NavAppearanceModifier: ViewModifier {
  init(backgroundColor: UIColor, foregroundColor: UIColor, tintColor: UIColor?, hideSeparator: Bool) {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.titleTextAttributes = [.foregroundColor: foregroundColor]
    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
    navBarAppearance.backgroundColor = backgroundColor
    if hideSeparator {
      navBarAppearance.shadowColor = .clear
    }
    UINavigationBar.appearance().standardAppearance = navBarAppearance
    UINavigationBar.appearance().compactAppearance = navBarAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    if let tintColor = tintColor {
      UINavigationBar.appearance().tintColor = tintColor
    }
  }

  func body(content: Content) -> some View {
    content
  }
}

#Preview {
  LovelyPreview {
    HomePage()
  }
}
