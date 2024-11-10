import ConfettiSwiftUI
import Haptico
import StoreKit
import SwiftData
import SwiftUI

struct SettingView: View {
  @Environment(NavigationContext.self) private var navigationContext
  @EnvironmentObject var pref: Pref
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var storeVM: StoreVM
  let selectedDisplayMode: NavigationBarItem.TitleDisplayMode = .large

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Appearance"), footer: Text("3D Scrolling: Move messages to the background when it goes off-screen.")) {
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
            .if(pref.haptics) {
              $0.sensoryFeedback(.selection, trigger: pref.colorScheme)
            }
          }

          HStack {
            Label("3D Scrolling", systemImage: "m.circle")
              .symbolRenderingMode(.multicolor)
              .modifier(RippleEffect(at: .zero, trigger: pref.magicScrolling))
            Toggle("", isOn: $pref.magicScrolling)
          }
        }
        .textCase(.none)

        Section("ChatGPT") {
          NavigationLink {
            TextEditPageVIew(text: $pref.gptApiKey,
                             title: "ChatGPT API key",
                             fb: .empty,
                             description: apiKeyExplain,
                             links: apiKeyExplainLlinks)
          } label: {
            HStack {
              Label {
                Text("API Key")
              } icon: {
                Image(systemName: "key")
                  .foregroundColor(.accentColor)
              }
              Spacer()
              Text(pref.gptApiKey)
                .lineLimit(1)
                .foregroundColor(.secondary)
            }
          }
          NavigationLink {
            ProxyView($pref.gptUseProxy, $pref.gptProxyHost)
              .navigationTitle("Proxy")
              .toolbarTitleDisplayMode(.inline)
          } label: {
            HStack {
              Label {
                Text("Proxy")
              } icon: {
                Image(systemName: "network")
                  .foregroundColor(.accentColor)
              }
              Spacer()
              Text(pref.gptUseProxy ? "On" : "Off")
                .foregroundColor(.secondary)
            }
          }
          if !pref.gptApiKey.isEmpty {
            TestButton {
              var c: ChatGPTContext
              if pref.gptUseProxy && !pref.gptProxyHost.isEmpty {
                c = ChatGPTContext(apiKey: pref.gptApiKey,
                                   proxyHost: pref.gptProxyHost,
                                   timeout: 5.0)
              } else {
                c = ChatGPTContext(apiKey: pref.gptApiKey, timeout: 5.0)
              }

              do {
                let res = try await c.hello()
                HapticsService.shared.shake(.success)
                return .succeeded(res)
              } catch {
                HapticsService.shared.shake(.error)
                return .failed(error.localizedDescription)
              }
            }
          }
        }.textCase(.none)

        Section(header: Text("App"), footer: Text("Reuse Text: Double-tap a message to input it, and double-tap again to withdraw.")) {
          HStack {
            Label("Haptics Feedback", systemImage: "iphone.gen2.radiowaves.left.and.right")
              .symbolRenderingMode(.multicolor)
              .modifier(RippleEffect(at: .zero, trigger: pref.haptics))
            Toggle("", isOn: $pref.haptics)
          }
          HStack {
            Label("Double Tap", systemImage: "hand.tap")
              .symbolRenderingMode(.multicolor)
            Spacer()
            Picker("Double Tap", selection: $pref.doubleTapAction) {
              ForEach(DoubleTapAction.allCases, id: \.self) { c in
                Text("\(c.rawValue)")
              }
            }
            .labelsHidden()
            .if(pref.haptics) {
              $0.sensoryFeedback(.selection, trigger: pref.doubleTapAction)
            }
          }
        }.textCase(.none)

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

        Section("") {
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
          }
        }
        .textCase(.none)

        Color.clear.frame(height: 100)
          .listRowBackground(Color.clear)
      }
      .animation(.default, value: colorScheme)
      .confettiCannon(counter: $storeVM.coffeeCount, num: 100, radius: 400)
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
