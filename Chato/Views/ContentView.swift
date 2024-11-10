import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject var storeVM = StoreVM()
  @ObservedObject var pref = Pref.shared
  @Environment(\.colorScheme) private var colorScheme
  @StateObject private var openAIServiceProvider: OpenAIServiceProvider

  init() {
    if Pref.shared.gptUseProxy {
      _openAIServiceProvider = StateObject(wrappedValue: OpenAIServiceProvider(apiKey: Pref.shared.gptApiKey, baseUrl: Pref.shared.gptProxyHost))
    } else {
      _openAIServiceProvider = StateObject(wrappedValue: OpenAIServiceProvider(apiKey: Pref.shared.gptApiKey))
    }
  }

  var body: some View {
    HomePage()
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(pref)
      .preferredColorScheme(pref.computedColorScheme)
      .environment(\.openAIService, openAIServiceProvider.service)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
