import SwiftUI

@Observable
class NavigationContext {
  var detent: PresentationDetent = .medium

  var path: NavigationPath = .init()

  func gotoHomePage() {
    path.removeLast(path.count)
  }
}
