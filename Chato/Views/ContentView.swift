import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var storeVM = StoreVM()
  @StateObject private var pref = Pref.shared
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let openai = OpenAIServiceProvider(apiKey: pref.gptApiKey, endpint: pref.resolvedEndpoint)

    let aiClient = AIClientProvider(endpoint: pref.resolvedEndpoint, apiKey: pref.gptApiKey, timeout: 5)

    HomePage()
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(pref)
      .preferredColorScheme(pref.computedColorScheme)
      .environment(\.openAIService, openai.service)
      .environment(\.aiClient, aiClient.service)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
