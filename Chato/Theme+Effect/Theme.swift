import SwiftUI

public extension View {
  func lovelyRow() -> some View {
    modifier(LoveRowView())
  }
}

struct LoveRowView: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var pref: Pref

  func body(content: Content) -> some View {
    content
      .if(colorScheme == .light) {
        $0.listRowBackground(
          Color.clear
            .overlay {
              if pref.wallpaperIndex == 0 {
                Rectangle()
                  .fill(.white)
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .shadow(color: .gray.opacity(0.2), radius: 5, y: 5)
                  .padding(.vertical, 2)
              } else {
                Rectangle()
                  .fill(BackgroundStyle.background.opacity(0.7))
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .padding(.vertical, 2)
              }
            })
            .listRowSeparator(.hidden)
      }
      .if(colorScheme == .dark) {
        $0.listRowBackground(
          Rectangle()
            .fill(BackgroundStyle.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.vertical, 2)
            .overlay {
              Rectangle()
                .fill(HierarchicalShapeStyle.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.vertical, 2)
            })
            .listRowSeparator(.hidden)
      }
  }
}

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
