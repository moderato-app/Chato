import Haptico
import SwiftUI
import SwiftOpenAI

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
        ProxyView($pref.gptEnableEndpoint, $pref.gptBaseURL)
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
          Text(pref.gptEnableEndpoint ? "On" : "Off")
            .foregroundColor(.secondary)
        }
      }
    } header: { Text("ChatGPT") } footer: {
      if !pref.gptApiKey.isEmpty {
        TestButton {
          let openai = pref.gptEnableEndpoint ? OpenAIServiceFactory.service(apiKey: pref.gptApiKey, overrideBaseURL: pref.gptBaseURL) : OpenAIServiceFactory.service(apiKey: pref.gptApiKey)
          do {
            
            let res = try await openai.hello()
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
    Form {
      ChatGPTSettingSection()
    }
  }
}
