import Haptico
import SwiftOpenAI
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
        EndpointView($pref.gptEnableEndpoint, $pref.gptEndpoint)
          .navigationTitle("Endpoint")
          .toolbarTitleDisplayMode(.inline)
      } label: {
        HStack {
          Label {
            Text("Endpoint")
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
          let openai = pref.gptEnableEndpoint ? OpenAIServiceProvider(apiKey: pref.gptApiKey, endpint: pref.gptEndpoint, timeout: 5) : OpenAIServiceProvider(apiKey: pref.gptApiKey, timeout: 5)
          do {
            let res = try await openai.service.hello()
            HapticsService.shared.shake(.success)
            return .succeeded(res)
          } catch {
            HapticsService.shared.shake(.error)
            return .failed("\(error)")
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
