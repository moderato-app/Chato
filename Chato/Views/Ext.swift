import SwiftUI

private struct SoftFeedbackModifier<T>: ViewModifier where T: Equatable {
  @EnvironmentObject var pref: Pref
  let sensor: SensoryFeedback
  let triggers: [T]

  func body(content: Content) -> some View {
    content
      .if(pref.haptics) {
        $0.sensoryFeedback(sensor, trigger: triggers)
      }
  }
}

public extension View {
  func softFeedback<T>(_ triggers: T...) -> some View where T: Equatable {
    modifier(SoftFeedbackModifier(sensor: .impact(flexibility: .soft), triggers: triggers))
  }

  func selectionFeedback<T>(_ triggers: T...) -> some View where T: Equatable {
    modifier(SoftFeedbackModifier(sensor: .selection, triggers: triggers))
  }
}
