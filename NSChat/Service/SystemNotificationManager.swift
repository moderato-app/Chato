import SystemNotification
import SwiftUI

class SystemNotificationManager: ObservableObject {
  static let shared = SystemNotificationManager()
  
  private init() {}
  
  @MainActor
  func showWebSearchNotification(enabled: Bool, context: SystemNotificationContext) {
    context.present {
      SystemNotificationMessage(
        icon: Image(systemName: "globe")
          .foregroundStyle(enabled ? Color.accentColor : Color.primary),
        title: enabled ? "Web Search" : "Web Search",
        text: enabled ? "On" : "Off"
      )
    }
  }
}

