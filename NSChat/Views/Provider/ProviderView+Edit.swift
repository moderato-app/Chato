import os
import SwiftData
import SwiftUI

struct ProviderDetailView: View {
  @Environment(\.modelContext) private var modelContext

  @Bindable var provider: Provider

  @State private var searchText = ""

  var body: some View {
    List {
      ProviderConfigurationForm(
        providerType: $provider.type,
        alias: $provider.alias,
        apiKey: $provider.apiKey,
        endpoint: $provider.endpoint,
        enabled: $provider.enabled
      )

      ModelListSection(provider: provider, searchText: $searchText)
    }
    .animation(.default, value: provider.models.map { $0.persistentModelID })
    .navigationTitle(provider.displayName)
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $searchText)
    .onDisappear {
      try? modelContext.save()
    }
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "My OpenAI", apiKey: "test-key")
  container.mainContext.insert(provider)

  return NavigationStack {
    ProviderDetailView(provider: provider)
      .modelContainer(container)
  }
}
