import os
import SwiftData
import SwiftUI

struct EditModelView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Bindable var model: ModelEntity
  
  @State private var modelId: String
  @State private var modelName: String
  @State private var contextLength: String
  
  init(model: ModelEntity) {
    self.model = model
    _modelId = State(initialValue: model.modelId)
    _modelName = State(initialValue: model.modelName ?? "")
    _contextLength = State(initialValue: model.contextLength.map { String($0) } ?? "")
  }
  
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
    model.contextLength = Int(contextLength)
    
    AppLogger.data.info("Updated model: \(modelId)")
    
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

