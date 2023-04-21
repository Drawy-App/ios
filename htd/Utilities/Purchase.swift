//
//  Purchase.swift
//  htd
//
//  Created by Alexey Landyrev on 05.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import RealmSwift
import StoreKit

class UserPayments: Object {
    @objc dynamic var id = 0
    let products = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Purchase: NSObject {
    static let sharedInstance = Purchase()
    var payments: UserPayments?
    let realm: Realm
    private var updates: Task<Void, Never>? = nil
    
    static let unlockAllId = "landyrev.htd.unlock_all"
    
    override init() {
        self.realm = try! Realm()
        self.payments = self.realm.object(ofType: UserPayments.self, forPrimaryKey: 0)
        super.init()

        if payments == nil {
            try! realm.write {
                self.payments = realm.create(UserPayments.self)
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeUpdates() {
        updates = self.observeTransactionUpdates()
    }
    
    func onPurchased(_ product: Product, _ tx: Transaction) async throws -> Bool {
        Analytics.sharedInstance.paidAction(product, transactionId: tx.id.formatted())
        self.savePurchase(product.id)
        return true;
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case let .success(.verified(tx)):
            await tx.finish()
            return try await onPurchased(product, tx);
        case let .success(.unverified(_, error)):
            Analytics.sharedInstance.captureError(error)
            return false;
        case .pending:
            return false;
        case .userCancelled:
            return false;
        @unknown default:
            return false;
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
    }
    
    func retrieveInfo(_ productId: String) async throws -> Product? {
        let products = try await Product.products(for: [productId])
        return products.first
    }
    
    func logError(_ error: Error, _ productId: String) {
        Analytics.sharedInstance.captureError(error)
        Analytics.sharedInstance.event("payment_error", params: [
            productId: [
                "message": error
            ]
        ])
    }
    
    private func savePurchase(_ productId: String) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.payments!.products.append(Purchase.unlockAllId)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.savePurchase(transaction.productID)
            }
        }
    }
}

extension Purchase: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
