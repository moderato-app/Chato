import Haptico
import SwiftUI

struct ChatGPTSettingSection: View {
  @EnvironmentObject var pref: Pref

  var body: some View {
    Section {
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
    } header: { Text("ChatGPT") } footer: {
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
        .font(.footnote)
      }
    }
    .textCase(.none)
  }
}

#Preview("SettingView") {
  LovelyPreview {
    Form{
      ChatGPTSettingSection()
    }
  }
}
