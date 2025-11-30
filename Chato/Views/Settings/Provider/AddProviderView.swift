// Created for Chato in 2025

import SwiftUI
import SwiftData
import os

struct AddProviderView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @State private var selectedType: ProviderType = .openAI
  @State private var alias: String = ""
  @State private var apiKey: String = ""
  @State private var endpoint: String = ""
  @State private var enabled: Bool = true
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          Picker("Provider Type", selection: $selectedType) {
            ForEach(ProviderType.allCases, id: \.self) { type in
              Label {
                Text(type.displayName)
              } icon: {
                Image(systemName: type.iconName)
              }
              .tag(type)
            }
          }
        } header: {
          Text("Type")
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
        } footer: {
          Text("Leave endpoint empty to use default")
        }
        
        Section {
          Toggle("Enabled", isOn: $enabled)
        }
      }
      .navigationTitle("Add Provider")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            addProvider()
          }
          .disabled(apiKey.isEmpty)
        }
      }
    }
  }
  
  private func addProvider() {
    let provider = Provider(
      type: selectedType,
      alias: alias,
      apiKey: apiKey,
      endpoint: endpoint,
      enabled: enabled
    )
    
    modelContext.insert(provider)
    
    AppLogger.data.info("Added new provider: \(provider.displayName)")
    
    dismiss()
  }
}

#Preview {
  AddProviderView()
    .modelContainer(ModelContainer.preview())
}

