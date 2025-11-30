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

  var body: some View {
    NavigationView {
      List {
        appearanceSection
        
        providersSection
        
        ChatGPTSettingSection()
        
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
      .confettiCannon(counter: $storeVM.coffeeCount, num: 100, radius: 400)
      .sheet(isPresented: $showingAddProvider) {
        AddProviderView()
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
