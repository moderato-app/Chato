import SwiftUI

struct DangerZoneView: View {
  @Environment(\.modelContext) private var modelContext

  @State private var isDeleteAllChatsPresented = false
  @State private var isDeleteAllPromptsPresented = false

  var body: some View {
    List {
      Section("") {
        Button("Delete All Chats", systemImage: "trash", role: .destructive) {
          isDeleteAllChatsPresented.toggle()
        }
        .symbolRenderingMode(.multicolor)
      }
      .padding(.vertical, -15)
      Section("") {
        Button("Delete All Prompts", systemImage: "trash", role: .destructive) {
          isDeleteAllPromptsPresented.toggle()
        }
        .symbolRenderingMode(.multicolor)
      }.textCase(.none)
        .padding(.vertical, -15)
    }

    .confirmationDialog("Delete All Chats?",
                        isPresented: $isDeleteAllChatsPresented,
                        titleVisibility: .visible)
    {
      Button("Delete All Chats.", role: .destructive) {
        modelContext.clearAll(Chat.self)
      }
    }
    .confirmationDialog("Delete All Prompts?",
                        isPresented: $isDeleteAllPromptsPresented,
                        titleVisibility: .visible)
    {
      Button("Delete All Prompts.", role: .destructive) {
        modelContext.clearAll(Prompt.self)
      }
    }
    .navigationTitle("Danger Zone")
  }
}

#Preview {
  NavigationStack {
    DangerZoneView()
  }
}
