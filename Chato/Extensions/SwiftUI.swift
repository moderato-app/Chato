import Combine
import Foundation
import SwiftData
import SwiftUI
import Throttler
import VisualEffectView

struct SwitchablePickerStyle: ViewModifier {
  let isNavi: Bool
  func body(content: Content) -> some View {
    if isNavi {
      content.pickerStyle(.navigationLink)
    } else {
      content.pickerStyle(.menu)
    }
  }
}

struct SwitchableListRowInsets: ViewModifier {
  let apply: Bool
  let insets: EdgeInsets

  init(_ apply: Bool, _ insets: EdgeInsets) {
    self.apply = apply
    self.insets = insets
  }

  func body(content: Content) -> some View {
    if apply {
      content.listRowInsets(insets)
    } else {
      content
    }
  }
}

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

extension View {
  @ViewBuilder func `apply`<Content: View>(transform: (Self) -> Content) -> some View {
      transform(self)
  }
}

struct SwitchableScrollView: ViewModifier {
  let id: PersistentIdentifier?

  init(_ id: PersistentIdentifier?) {
    self.id = id
  }

  func body(content: Content) -> some View {
    if let id = id {
      ScrollViewReader { proxy in
        content.onAppear {
          withAnimation {
            proxy.scrollTo(id, anchor: .center)
          }
        }
      }
    } else {
      content
    }
  }
}

struct JustScrollView: ViewModifier {
  let id: PersistentIdentifier?

  init(_ id: PersistentIdentifier?) {
    self.id = id
  }

  func body(content: Content) -> some View {
    ScrollViewReader { proxy in
      content.onAppear {
        if let id = id {
          withAnimation {
            proxy.scrollTo(id, anchor: .center)
          }
        }
      }
    }
  }
}

// https://stackoverflow.com/a/72026504
// tap anywhere to lose focus
public struct RemoveFocusOnTapModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
    #if os(iOS)
    .onTapGesture {
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #elseif os(macOS)
    .onTapGesture {
      DispatchQueue.main.async {
        NSApp.keyWindow?.makeFirstResponder(nil)
      }
    }
    #endif
  }
}

public extension View {
  func removeFocusOnTap() -> some View {
    modifier(RemoveFocusOnTapModifier())
  }
}

class KeyboardResponder: ObservableObject {
  @Published var isKeyboardVisible = false
  private var cancellables: Set<AnyCancellable> = []

  init() {
    let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
      .map { _ in true }

    let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
      .map { _ in false }

    Publishers.Merge(keyboardWillShow, keyboardWillHide)
      .assign(to: \.isKeyboardVisible, on: self)
      .store(in: &cancellables)
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r = CGFloat((int & 0xFF0000) >> 16) / 255
    let g = CGFloat((int & 0x00FF00) >> 8) / 255
    let b = CGFloat(int & 0x0000FF) / 255

    self.init(
      .sRGB,
      red: r,
      green: g,
      blue: b,
      opacity: 1
    )
  }
}

extension UIApplication {
  static var keyWindow: UIWindow? {
    UIApplication.shared
      .connectedScenes.lazy
      .compactMap { $0.activationState == .foregroundActive ? ($0 as? UIWindowScene) : nil }
      .first(where: { $0.keyWindow != nil })?
      .keyWindow
  }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
  static var defaultValue: EdgeInsets {
    UIApplication.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
  }
}

extension EnvironmentValues {
  var safeAreaInsets: EdgeInsets {
    self[SafeAreaInsetsKey.self]
  }
}

private extension UIEdgeInsets {
  var swiftUiInsets: EdgeInsets {
    EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
  }
}

struct ViewOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct YRange: Equatable {
  var yMin: CGFloat
  var yMax: CGFloat
  init(_ yMin: CGFloat, _ yMax: CGFloat) {
    self.yMin = yMin
    self.yMax = yMax
  }
}

struct ViewPoint: PreferenceKey {
  typealias Value = YRange
  static var defaultValue: Value = YRange(.zero, .zero)

  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

extension Spacer {
  static func widthPercent(_ percent: CGFloat) -> some View {
    return Spacer().containerRelativeFrame(.horizontal) { w, _ in w * percent }
  }

  static func heightPercent(_ percent: CGFloat) -> some View {
    return Spacer().containerRelativeFrame(.vertical) { h, _ in h * percent }
  }
}

extension PresentationDetent {
  static let allDetents: Set<PresentationDetent> = Set([.medium, .large])
  static let mediumDetents: Set<PresentationDetent> = Set([.medium])
  static let largeDetents: Set<PresentationDetent> = Set([.large])
}

extension ShapeStyle where Self == Color {
  static var random: Color {
    Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }
}

extension View {
  static func printChagesWhenDebug() {
    #if DEBUG
    let _ = _printChanges()
    #endif
  }
}

struct RectDetector: ViewModifier {
  @Binding var rect: CGRect
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { proxy in
          Color.clear.onAppear {
            self.rect = proxy.frame(in: .global)
            print("newRect: \(self.rect)")
            print("newRect.maxY: \(self.rect.maxY)")
          }
          .onChange(of: proxy.frame(in: .global)) { _, newRect in
            self.rect = newRect
            print("newRect: \(newRect)")
            print("newRect.maxY: \(newRect.maxY)")
            print("newRect.height: \(newRect.height)")
          }
        }
      )
  }
}

extension View {
  @ViewBuilder func detectRect(_ rect: Binding<CGRect>) -> some View {
    modifier(RectDetector(rect: rect))
  }
}


struct SizeDetector: ViewModifier {
  @Binding var size: CGSize
  func body(content: Content) -> some View {
    content
      .background(GeometryReader { proxy in
        Color.clear.onAppear {
          self.size = proxy.size
        }
        .onChange(of: proxy.size) { _, newSize in
          self.size = newSize
        }
      }
      )
  }
}

extension View {
  @ViewBuilder func detectSize(_ size: Binding<CGSize>) -> some View {
    modifier(SizeDetector(size: size))
  }
}

struct TransNaviModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme

  var visualTint: Color {
    colorScheme == .dark ? .black : .white
  }

  func body(content: Content) -> some View {
    content
      .toolbarBackground(.hidden, for: .navigationBar)
      .safeAreaInset(edge: .top, spacing: 0) {
        VisualEffect(colorTint: visualTint, colorTintAlpha: 0.1, blurRadius: 18, scale: 1)
          .ignoresSafeArea(edges: .top)
          .frame(height: 0)
      }
  }
}

public extension View {
  func transNavi() -> some View {
    modifier(TransNaviModifier())
  }
}
