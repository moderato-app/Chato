import SwiftData
import SwiftUI

struct ModelContainerPreview<Content: View>: View {
  var content: () -> Content
  let container: ModelContainer

  init(@ViewBuilder content: @escaping () -> Content, modelContainer: @escaping () throws -> ModelContainer) {
    self.content = content
    do {
      self.container = try MainActor.assumeIsolated(modelContainer)
    } catch {
      fatalError("Failed to create the model container: \(error.localizedDescription)")
    }
  }

  init(_ modelContainer: @escaping () throws -> ModelContainer, @ViewBuilder content: @escaping () -> Content) {
    self.init(content: content, modelContainer: modelContainer)
  }

  var body: some View {
    content()
      .modelContainer(container)
  }
}

struct LovelyPreview<Content: View>: View {
  @StateObject var storeVM: StoreVM = StoreVM();

  var content: () -> Content
  let container: ModelContainer

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.container = MainActor.assumeIsolated(ModelContainer.preview)
  }

  var body: some View {
    content()
      .modelContainer(container)
      .environmentObject(EM.shared)
      .environmentObject(storeVM)
      .environmentObject(Pref.shared)
  }
}
