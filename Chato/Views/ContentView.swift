import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var storeVM = StoreVM()
  @StateObject private var pref = Pref.shared

  var body: some View {
    let openai = OpenAIServiceProvider(apiKey: pref.gptApiKey, endpint: pref.resolvedEndpoint)
    let aiClient = AIClientProvider(endpoint: pref.resolvedEndpoint, apiKey: pref.gptApiKey, timeout: 5)

    GeometryReader { geometry in
      HomePage()
        .environmentObject(EM.shared)
        .environmentObject(storeVM)
        .environmentObject(pref)
        .preferredColorScheme(pref.computedColorScheme)
        .environment(\.openAIService, openai.service)
        .environment(\.aiClient, aiClient.service)
        .environment(\.screenSize, geometry.size)
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
