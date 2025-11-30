// Created for Chato in 2025

import SwiftData
import SwiftUI

struct EditProviderView: View {
  @Environment(\.dismiss) private var dismiss
  
  let provider: Provider
  
  @State private var alias: String
  @State private var apiKey: String
  @State private var endpoint: String
  @State private var enabled: Bool
  
  init(provider: Provider) {
    self.provider = provider
    _alias = State(initialValue: provider.alias ?? "")
    _apiKey = State(initialValue: provider.apiKey ?? "")
    _endpoint = State(initialValue: provider.endpoint ?? "")
    _enabled = State(initialValue: provider.enabled)
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          HStack {
            Label {
              Text("Provider Type")
            } icon: {
              Image(systemName: provider.iconName)
                .foregroundColor(.accentColor)
            }
            Spacer()
            Text(provider.type.displayName)
              .foregroundColor(.secondary)
          }
        }
        
        Section {
          TextField("Alias (Optional)", text: $alias)
          
          TextField("API Key", text: $apiKey)
            .textContentType(.password)
          
          TextField("Endpoint (Optional)", text: $endpoint)
            .textContentType(.URL)
            .autocapitalization(.none)
        } header: {
          Text("Configuration")
        }
        
        Section {
          Toggle("Enabled", isOn: $enabled)
        }
      }
      .navigationTitle("Edit Provider")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveChanges()
          }
          .disabled(apiKey.isEmpty)
        }
      }
    }
  }
  
  private func saveChanges() {
    provider.alias = alias
    provider.apiKey = apiKey
    provider.endpoint = endpoint
    provider.enabled = enabled
    
    dismiss()
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "My OpenAI", apiKey: "test-key")
  container.mainContext.insert(provider)
  
  return EditProviderView(provider: provider)
    .modelContainer(container)
}
