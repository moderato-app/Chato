import SwiftUI

extension SettingView {
  @ViewBuilder
  var appSection: some View {
    Section {
      HStack {
        Label("Haptic Feedback", systemImage: "iphone.gen2.radiowaves.left.and.right")
          .symbolRenderingMode(.multicolor)
          .modifier(RippleEffect(at: .zero, trigger: pref.haptics))
        Toggle("", isOn: $pref.haptics)
      }
      
      HStack {
        Label("Double Tap", systemImage: "hand.tap")
          .symbolRenderingMode(.multicolor)
        Spacer()
        Picker("Double Tap", selection: $pref.doubleTapAction.animation()) {
          ForEach(DoubleTapAction.allCases, id: \.self) { c in
            Text("\(c.rawValue)")
          }
        }
        .labelsHidden()
        .selectionFeedback(pref.doubleTapAction)
      }
      
      HStack {
        Label("Tripple Tap", systemImage: "hand.tap")
          .symbolRenderingMode(.multicolor)
        Spacer()
        Picker("Tripple Tap", selection: $pref.trippleTapAction.animation()) {
          ForEach(DoubleTapAction.allCases, id: \.self) { c in
            Text("\(c.rawValue)")
          }
        }
        .labelsHidden()
        .selectionFeedback(pref.trippleTapAction)
      }
    } header: {
      Text("App")
    } footer: {
      if pref.doubleTapAction == .reuse {
        Text("Double-tap a message to input it, and double-tap again to withdraw.")
      }
      if pref.trippleTapAction == .reuse {
        Text("Tripple-tap a message to input it, and tripple-tap again to withdraw.")
      }
    }
    .textCase(.none)
  }
}

