//
//  Purchase.swift
//  htd
//
//  Created by Alexey Landyrev on 05.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import SwiftyStoreKit
import RealmSwift
import StoreKit

class UserPayments: Object {
    @objc dynamic var id = 0
    let products = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Purchase {
    static let sharedInstance = Purchase()
    var payments: UserPayments?
    let realm: Realm
    
    static let unlockAllId = "landyrev.htd.unlock_all"
    
    init() {
        self.realm = try! Realm()
        self.payments = self.realm.object(ofType: UserPayments.self, forPrimaryKey: 0)
        if payments == nil {
            try! realm.write {
                self.payments = realm.create(UserPayments.self)
            }
        }
    }
    
    func purchase(_ productId: String, callback: @escaping (_ result: Bool, _ error: Error?) -> Void ) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                Analytics.sharedInstance.paidAction(
                    purchase.product,
                    transactionId: purchase.transaction.transactionIdentifier!
                )
                self.savePurchase(purchase.productId)
                callback(true, nil)
            case .error(let error):
                switch error.code {
                case .unknown: self.logError("Unknown error. Please contact support", productId)
                case .clientInvalid: self.logError("Not allowed to make the payment", productId)
                case .paymentCancelled: self.logError("Payment cancelled", productId)
                case .paymentInvalid: self.logError("The purchase identifier was invalid", productId)
                case .paymentNotAllowed: self.logError("The device is not allowed to make the payment", productId)
                case .storeProductNotAvailable: self.logError("The product is not available in the current storefront", productId)
                case .cloudServicePermissionDenied: self.logError("Access to cloud service information is not allowed", productId)
                case .cloudServiceNetworkConnectionFailed: self.logError("Could not connect to the network", productId)
                case .cloudServiceRevoked: self.logError("User has revoked permission to use this cloud service", productId)
                }
                callback(false, error)
            }
        }
    }
    
    func restore(_ productId: String, callback: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                callback(false, nil)
            }
            else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    if purchase.productId == productId {
                        self.savePurchase(productId)
                        callback(true, nil)
                    }
                }
            }
            else {
                callback(false, nil)
            }
        }
    }
    
    func retrieveInfo(_ productId: String, callback: @escaping (_ product: SKProduct?, _ error: Error?) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                callback(product, nil)
                return
            }
            else {
                callback(nil, result.error)
                return
            }
        }
    }
    
    func logError(_ error: String, _ productId: String) {
        NSLog(error)
        Analytics.sharedInstance.event("payment_error", params: [
            productId: [
                "message": error
            ]
        ])
    }
    
    func completeTransaction() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.savePurchase(purchase.productId)
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    private func savePurchase(_ productId: String) {
        try! self.realm.write {
            self.payments!.products.append(Purchase.unlockAllId)
        }
    }
}
