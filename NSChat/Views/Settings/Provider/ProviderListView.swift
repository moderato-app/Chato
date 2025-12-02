import SwiftData
import SwiftUI

struct ProviderListView: View {
  @State var searchString = ""
  
  var body: some View {
    ListProvider(searchString: searchString)
      .searchable(text: $searchString)
      .animation(.easeInOut, value: searchString)
  }
}

private struct ListProvider: View {
  private static let sortOrder = [SortDescriptor(\Provider.createdAt, order: .reverse)]
  
  @Query(sort: \Provider.createdAt, order: .reverse) private var allProviders: [Provider]
  
  @State private var isAddProviderPresented = false
  @State private var isDeleteProviderConfirmPresented: Bool = false
  @State private var providersToDelete: [Provider] = []
  
  @Environment(\.modelContext) private var modelContext
  
  let searchString: String
  
  init(searchString: String) {
    self.searchString = searchString
  }
  
  private var providers: [Provider] {
    if searchString.isEmpty {
      return allProviders
    }
    return allProviders.filter { provider in
      provider.displayName.localizedStandardContains(searchString)
    }
  }
  
  var body: some View {
    List {
      if providers.isEmpty {
        Section {
          EmptyProviderCard {
            isAddProviderPresented = true
          }
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
        }
      } else {
        ForEach(providers) { provider in
          NavigationLink {
            ProviderDetailView(provider: provider)
          } label: {
            ProviderRow(provider: provider)
          }
        }
        .onDelete(perform: deleteProviders)
        
        Button {
          isAddProviderPresented = true
        } label: {
          HStack {
            Image(systemName: "plus.circle.fill")
            Text("Add Provider")
          }
        }
        .foregroundStyle(.tint)
      }
    }
    .listStyle(.plain)
    .animation(.default, value: providers.count)
    .navigationBarTitle("Providers")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          isAddProviderPresented = true
        } label: {
          PlusIcon()
        }
      }
    }
    .sheet(isPresented: $isAddProviderPresented) {
      AddProviderView()
    }
    .confirmationDialog(
      providersToDelete.count == 1 ? (providersToDelete.first?.displayName ?? "Provider") : "Delete \(providersToDelete.count) Providers",
      isPresented: $isDeleteProviderConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        for provider in providersToDelete {
          modelContext.delete(provider)
        }
        providersToDelete = []
      }
    } message: {
      if providersToDelete.count == 1 {
        Text("This provider will be deleted.")
      } else {
        Text("\(providersToDelete.count) providers will be deleted.")
      }
    }
  }
  
  func deleteProviders(at offsets: IndexSet) {
    providersToDelete = offsets.map { providers[$0] }
    isDeleteProviderConfirmPresented = true
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    NavigationStack {
      ProviderListView()
    }
  }
}

