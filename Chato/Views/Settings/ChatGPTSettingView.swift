import SwiftUI

import Haptico
import SwiftData
import SwiftUI

struct ChatGPTSettingView: View {
  @Environment(NavigationContext.self) private var navigationContext
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var pref: Pref

  let selectedDisplayMode: NavigationBarItem.TitleDisplayMode = .large

  @State private var isDeleteAllChatsPresented = false

  var body: some View {
    NavigationView {
      List {
        Section("ChatGPT") {
          NavigationLink {
            TextEditPageVIew(text: $pref.gptApiKey,
                             title: "ChatGPT API Key",
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
          }.disabled(pref.gptApiKey.isEmpty)
        }.textCase(.none)
      }
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }.foregroundColor(.accentColor)
        }
      }
      .navigationTitle("ChatGPT Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  @MainActor
  private func clearAllChats() {
    do {
      try modelContext.delete(model: Chat.self)
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

#Preview("SettingView") {
  LovelyPreview {
    ChatGPTSettingView()
  }
}
