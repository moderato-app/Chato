import SwiftUI
import TipKit
import os

struct DebugZoneView: View {
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var pref: Pref

  var body: some View {
    Form {
      Section("") {
        Button("Reset User Defauts", systemImage: "arrow.clockwise") {
          pref.reset()
        }
        Button("Reset Tips", systemImage: "arrow.clockwise") {
          try? Tips.resetDatastore()
          try? Tips.configure()
        }
      }
      Section("Prompts") {
        Button("Fill Prompts", systemImage: "p.square") {
          do {
            try fillPrompts(modelContext, save: true)
          } catch {
            AppLogger.logError(.from(
              error: error,
              operation: "填充提示词",
              component: "DebugZoneView",
              userMessage: "填充提示词失败"
            ))
          }
        }
        Button("Remove Preset Prompts", systemImage: "trash", role: .destructive) {
          do {
            try modelContext.removePresetPrompts()
            try modelContext.save()
          } catch {
            AppLogger.logError(.from(
              error: error,
              operation: "删除预设提示词",
              component: "DebugZoneView",
              userMessage: "删除预设提示词失败"
            ))
          }
        }
      }
    }
    .navigationTitle("Debug Zone")
  }
}

#Preview {
  NavigationStack {
    DebugZoneView()
  }
}
