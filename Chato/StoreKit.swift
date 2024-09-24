import Foundation
import StoreKit

typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState


class StoreVM: ObservableObject {
  @Published private(set) var presetProducts: [Product] = []
  @Published private(set) var purchasedSubscriptions: [Product] = []
  @Published private(set) var purchasedConsumable: [Product] = []
  @Published private(set) var subscriptionGroupStatus: RenewalState?

  @Published public var coffeeCount: Int {
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
    print("listenForTransactions ended...")
  }
    
  func listenForTransactions() -> Task<Void, Error> {
    print("listenForTransactions started...")
    return Task.detached {
      // Iterate through any transactions that don't come from a direct call to `purchase()`.
      for await result in Transaction.updates {
        do {
          let transaction = try self.checkVerified(result)
          await self.updateCustomerProductStatus()
          await transaction.finish()
        } catch {
          print("transaction failed verification")
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
      print("Failed product request from app store server: \(error)")
    }
  }
    
  // purchase the product
  func purchase(_ product: Product) async throws -> Transaction? {
    let result = try await product.purchase()
        
    switch result {
    case .success(let verification):
      // Check whether the transaction is verified. If it isn't,
      // this function rethrows the verification error.
      let transaction = try checkVerified(verification)
            
      // The transaction is verified. Deliver content to the user.
      await updateCustomerProductStatus()
            
      // Always finish a transaction.
      await transaction.finish()

      return transaction
    case .userCancelled, .pending:
      return nil
    default:
      return nil
    }
  }
    
  // purchase the product
  func purchase(_ productId: String) async throws -> Transaction? {
    guard let product = presetProducts.first(where: { $0.id == productId }) else {
      return nil
    }
    let result = try await product.purchase()
        
    switch result {
    case .success(let verification):
      // Check whether the transaction is verified. If it isn't,
      // this function rethrows the verification error.
      let transaction = try checkVerified(verification)
            
      // The transaction is verified. Deliver content to the user.
      await updateCustomerProductStatus()
            
      // Always finish a transaction.
      await transaction.finish()

      return transaction
    case .userCancelled, .pending:
      return nil
    default:
      return nil
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
              print("coffee +1")
              coffeeCount += 1
            }
          }
        default:
          break
        }
        // Always finish a transaction.
        await transaction.finish()
      } catch {
        print("failed updating products")
      }
    }
  }
}

public enum StoreError: Error {
  case failedVerification
}
