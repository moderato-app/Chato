import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject var storeVM = StoreVM()
  @ObservedObject var pref = Pref.shared
  @Environment(\.colorScheme) private var colorScheme
 
  var body: some View {
    
    let openai = pref.gptEnableEndpoint ?  OpenAIServiceProvider(apiKey: pref.gptApiKey, endpint: pref.gptEndpoint) : OpenAIServiceProvider(apiKey: pref.gptApiKey)

    HomePage()
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(pref)
      .preferredColorScheme(pref.computedColorScheme)
      .environment(\.openAIService, openai.service)
  }
}

#Preview {
  ContentView()
    .modelContainer(ModelContainer.preview())
}
