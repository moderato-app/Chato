import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject var storeVM = StoreVM()
  @ObservedObject var pref = Pref.shared
  @Environment(\.colorScheme) private var colorScheme
  @StateObject private var openAIServiceProvider: OpenAIServiceProvider

  init() {
    if Pref.shared.gptEnableEndpoint {
      _openAIServiceProvider = StateObject(wrappedValue: OpenAIServiceProvider(apiKey: Pref.shared.gptApiKey, baseUrl: Pref.shared.gptBaseURL))
    } else {
      _openAIServiceProvider = StateObject(wrappedValue: OpenAIServiceProvider(apiKey: Pref.shared.gptApiKey))
    }
  }
  
  var body: some View {
    let o = OpenAIServiceProvider(apiKey: pref.gptApiKey, baseUrl: pref.gptBaseURL)
    HomePage()
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(pref)
      .preferredColorScheme(pref.computedColorScheme)
      .environment(\.openAIService, o.service)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
