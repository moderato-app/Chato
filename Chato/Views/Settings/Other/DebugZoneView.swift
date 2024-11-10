import SwiftUI
import TipKit

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
            print("try fillPrompts(modelContext,save: true) :\(error)")
          }
        }
        Button("Remove Preset Prompts", systemImage: "trash", role: .destructive) {
          do {
            try modelContext.removePresetPrompts()
            try modelContext.save()
          } catch {
            print("try fillPrompts(modelContext,save: true) :\(error)")
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
