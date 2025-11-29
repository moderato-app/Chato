// Created for Chato in 2025

import SwiftUI
import SwiftData
import os

struct AddCustomModelView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  let provider: Provider
  
  @State private var modelId: String = ""
  @State private var modelName: String = ""
  @State private var contextLength: String = ""
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Model ID", text: $modelId)
            .autocapitalization(.none)
            .autocorrectionDisabled()
          
          TextField("Display Name (Optional)", text: $modelName)
          
          TextField("Context Length (Optional)", text: $contextLength)
            .keyboardType(.numberPad)
        } header: {
          Text("Model Information")
        } footer: {
          Text("Model ID is required and must be unique")
        }
      }
      .navigationTitle("Add Custom Model")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") {
            addModel()
          }
          .disabled(modelId.isEmpty)
        }
      }
    }
  }
  
  private func addModel() {
    let contextLengthInt = Int(contextLength)
    
    let model = ModelEntity(
      id: modelId,
      name: modelName.isEmpty ? nil : modelName,
      contextLength: contextLengthInt,
      isCustom: true,
      provider: provider
    )
    
    modelContext.insert(model)
    
    AppLogger.data.info("Added custom model: \(modelId) to \(provider.displayName)")
    
    dismiss()
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "My OpenAI", apiKey: "test-key")
  container.mainContext.insert(provider)
  
  return AddCustomModelView(provider: provider)
    .modelContainer(container)
}

