import ConfettiSwiftUI
import os
import StoreKit
import SwiftData
import SwiftUI

struct SettingView: View {
  @EnvironmentObject var pref: Pref
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var storeVM: StoreVM
  
  @Query(sort: \Provider.createdAt, order: .reverse) var providers: [Provider]
  
  @State var showingAddProvider = false
  @State var isDeleteProviderConfirmPresented: Bool = false
  @State var providersToDelete: [Provider] = []
  
  let autoShowAddProvider: Bool
  
  init(autoShowAddProvider: Bool = false) {
    self.autoShowAddProvider = autoShowAddProvider
  }

  var body: some View {
    NavigationView {
      List {
        appearanceSection
        
        providersSection
                
        appSection
        
        OtherViewGroup()
        
        dangerZoneLink
        
        #if DEBUG
        debugZoneLink
        #endif
        
        purchaseSection
        
        Color.clear.frame(height: 100)
          .listRowBackground(Color.clear)
      }
      .animation(.default, value: colorScheme)
      .animation(.default, value: providers.count)
      .confettiCannon(trigger: $storeVM.coffeeCount, num: 100, radius: 400)
      .sheet(isPresented: $showingAddProvider) {
        AddProviderView()
      }
      .task {
        if autoShowAddProvider {
          try? await Task.sleep(for: .milliseconds(300))
          showingAddProvider = true
        }
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
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  LovelyPreview {
    SettingView()
  }
}
