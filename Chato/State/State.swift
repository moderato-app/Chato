import Foundation

@Observable
class UIState {
  static var shared = UIState()
  private init() {}
}
