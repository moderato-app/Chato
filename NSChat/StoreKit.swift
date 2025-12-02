import Foundation
import os
import StoreKit

class StoreVM: ObservableObject {
  @Published private(set) var presetProducts: [Product] = []
  @Published private(set) var purchasedSubscriptions: [Product] = []
  @Published private(set) var purchasedConsumable: [Product] = []

  @Published var coffeeCount: Int {
    didSet {
      UserDefaults.standard.set(coffeeCount, forKey: "coffeeCount")
    }
  }

  private let productIds: [String] = [cofferProductId]
    
  var updateListenerTask: Task<Void, Error>? = nil

  init() {
    coffeeCount = UserDefaults.standard.integer(forKey: "coffeeCount")

    // start a transaction listern as close to app launch as possible so you don't miss a transaction
    updateListenerTask = listenForTransactions()
        
    Task {
      await requestProducts()
            
      await updateCustomerProductStatus()
    }
  }
    
  deinit {
    updateListenerTask?.cancel()
    AppLogger.audit.debug("listenForTransactions ended...")
  }
  
  func listenForTransactions() -> Task<Void, Error> {
    AppLogger.audit.debug("listenForTransactions started...")
    return Task.detached {
      // Iterate through any transactions that don't come from a direct call to `purchase()`.
      for await result in Transaction.updates {
        do {
          let transaction = try self.checkVerified(result)
          await self.updateCustomerProductStatus()
          await transaction.finish()
        } catch {
          AppLogger.error.error("transaction failed verification: \(error.localizedDescription)")
        }
      }
    }
  }
    
  // Request the products
  @MainActor
  func requestProducts() async {
    do {
      // request from the app store using the product ids (hardcoded)
      presetProducts = try await Product.products(for: productIds)
    } catch {
      AppLogger.error.error("Failed product request from app store server: \(error.localizedDescription)")
    }
  }
    
  func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    // Check whether the JWS passes StoreKit verification.
    switch result {
    case .unverified:
      // StoreKit parses the JWS, but it fails verification.
      throw StoreError.failedVerification
    case .verified(let safe):
      // The result is verified. Return the unwrapped value.
      return safe
    }
  }

  @MainActor
  func updateCustomerProductStatus() async {
    for await result in Transaction.unfinished {
      do {
        // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
        let transaction = try checkVerified(result)
        switch transaction.productType {
        case .autoRenewable:
          if let subscription = presetProducts.first(where: { $0.id == transaction.productID }) {
            purchasedSubscriptions.append(subscription)
          }
        case .consumable:
          if let consume = presetProducts.first(where: { $0.id == transaction.productID }) {
            purchasedConsumable.append(consume)
            if consume.id == cofferProductId {
              AppLogger.audit.info("coffee +1")
              coffeeCount += 1
            }
          }
        default:
          break
        }
        // Always finish a transaction.
        await transaction.finish()
      } catch {
        AppLogger.error.error("failed updating products: \(error.localizedDescription)")
      }
    }
  }
}

enum StoreError: Error {
  case failedVerification
}
