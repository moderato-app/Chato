import os
import SwiftData
import SwiftUI

struct AddCustomModelView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  let provider: Provider
  
  @State private var modelId: String = ""
  @State private var modelName: String = ""
  
  var body: some View {
    NavigationStack {
      Form {
        Section("Model ID") {
          TextField("", text: $modelId)
        }
        Section("Model Name") {
          TextField("Optional", text: $modelName)
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
    let model = ModelEntity(
      provider: provider,
      modelId: modelId,
      modelName: modelName.isEmpty ? nil : modelName,
      contextLength: nil,
      isCustom: true,
    )
    
    modelContext.insert(model)
    
    // Force save to ensure SwiftData updates are persisted and view refreshes immediately
    do {
      try modelContext.save()
      AppLogger.data.info("Added custom model: \(modelId) to \(provider.displayName)")
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Add custom model",
        component: "AddCustomModelView"
      ))
    }
    
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
