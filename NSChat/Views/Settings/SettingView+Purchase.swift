import os
import StoreKit
import SwiftUI

extension SettingView {
  @ViewBuilder
  var purchaseSection: some View {
    Section {
      ProductView(id: cofferProductId)
        .productViewStyle(.compact)

      if storeVM.coffeeCount > 0 {
        let icons = CoffeeIcons(storeVM.coffeeCount)
        ScrollView(.horizontal) {
          HStack {
            ForEach(icons.indices, id: \.self) { i in
              Image(systemName: icons[i])
                .foregroundColor(randomColor(i))
            }
          }
        }
        .scrollIndicators(.hidden)
      }
    } footer: {
      HStack(alignment: .center, spacing: 0) {
        Image(systemName: "cup.and.saucer")
        Text(" × \(storeVM.coffeeCount)")
      }
    }
    .textCase(.none)
  }
  
}

