import os
import SwiftData
import SwiftUI

struct EditModelView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Bindable var model: ModelEntity
  
  @State private var modelId: String
  @State private var modelName: String
  
  init(model: ModelEntity) {
    self.model = model
    _modelId = State(initialValue: model.modelId)
    _modelName = State(initialValue: model.modelName ?? "")
  }
  
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
      .navigationTitle("Edit Model")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveModel()
          }
          .disabled(modelId.isEmpty)
        }
      }
    }
  }
  
  private func saveModel() {
    model.modelId = modelId
    model.modelName = modelName.isEmpty ? nil : modelName
    
    // Force save to ensure SwiftData updates are persisted and view refreshes immediately
    do {
      try modelContext.save()
      AppLogger.data.info("Updated model: \(modelId)")
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Update model",
        component: "EditModelView"
      ))
    }
    
    dismiss()
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "My OpenAI", apiKey: "test-key")
  container.mainContext.insert(provider)
  let model = ModelEntity(provider: provider, modelId: "gpt-4", modelName: "GPT-4", contextLength: 128)
  container.mainContext.insert(model)
  
  return EditModelView(model: model)
    .modelContainer(container)
}

