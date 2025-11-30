import SwiftUI

extension SettingView {
  @ViewBuilder
  var appearanceSection: some View {
    Section {
      VStack(alignment: .leading) {
        Label("Color Scheme", systemImage: "paintpalette")
          .symbolRenderingMode(.multicolor)
          .modifier(RippleEffect(at: .zero, trigger: pref.colorScheme))
        Picker("", selection: $pref.colorScheme) {
          ForEach(Pref.AppColorScheme.allCases, id: \.self) { c in
            Text("\(c.rawValue)")
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .selectionFeedback(pref.colorScheme)
      }

      HStack {
        Label("3D Scrolling", systemImage: "cube")
          .symbolRenderingMode(.multicolor)
        Toggle("", isOn: $pref.magicScrolling.animation())
      }
    } header: {
      Text("Appearance")
    } footer: {
      if pref.magicScrolling {
        Text("Move messages to the background when it goes off-screen.")
      }
    }
    .textCase(.none)
  }
}

