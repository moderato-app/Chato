import ConfettiSwiftUI
import StoreKit
import SwiftUI

struct SettingView: View {
  @EnvironmentObject var pref: Pref
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var storeVM: StoreVM

  var body: some View {
    NavigationView {
      List {
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

        } header: { Text("Appearance") }
          .textCase(.none)

        ChatGPTSettingSection()

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
        } header: { Text("App") } footer: {
          if pref.doubleTapAction == .reuse {
            Text("Double-tap a message to input it, and double-tap again to withdraw.")
          }
          if pref.trippleTapAction == .reuse {
            Text("Tripple-tap a message to input it, and tripple-tap again to withdraw.")
          }
        }
        .textCase(.none)

        OtherViewGroup()

        NavigationLink {
          DangerZoneView()
        } label: {
          Label {
            Text("Danger Zone")
          } icon: {
            Image(systemName: "exclamationmark.circle")
              .foregroundColor(.pink)
          }
        }

        #if DEBUG
        NavigationLink {
          DebugZoneView()
        } label: {
          Label {
            Text("Debug")
          } icon: {
            Image(systemName: "ladybug.circle")
              .foregroundColor(.teal)
          }
        }
        #endif

        Section {
          ProductView(id: cofferProductId)
            .productViewStyle(.compact)

          if storeVM.coffeeCount > 0 {
            let icons = CoffeeIcons(storeVM.coffeeCount)
            ScrollView(.horizontal) {
              HStack {
                ForEach(icons.indices, id: \.self) { i in
                  Image(systemName: icons[i])
                    .foregroundColor(randomColor(i))
                }
              }
            }
            .scrollIndicators(.hidden)
          }
        } footer: {
          HStack(alignment: .center, spacing: 0) {
            Image(systemName: "cup.and.saucer")
            Text(" × \(storeVM.coffeeCount)")
          }
        }
        .textCase(.none)

        Color.clear.frame(height: 100)
          .listRowBackground(Color.clear)
      }
      .animation(.default, value: colorScheme)
      .confettiCannon(trigger: $storeVM.coffeeCount, num: 100, radius: 400)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  func buy(product: Product) async {
    do {
      if try await storeVM.purchase(product) != nil {
        print("purchase succeeded")
      }
    } catch {
      print("purchase failed")
    }
  }

  func CoffeeIcons(_ count: Int) -> [String] {
    return (0 ..< count).map { i in
      if i % 2 == 0 {
        return "cup.and.saucer"
      } else {
        return "cup.and.saucer.fill"
      }
    }
  }

  func randomColor(_ i: Int) -> Color {
    let colors = [Color.primary,
                  Color.secondary,
                  Color.blue,
                  Color.pink,
                  Color.green,
                  Color.yellow,
                  Color.teal,
                  Color.indigo,
                  Color.yellow,
                  Color.purple,
                  Color.cyan]
    return colors[i % colors.count]
  }
}

#Preview {
  LovelyPreview {
    SettingView()
  }
}
