//
//  Analytics.swift
//  htd
//
//  Created by Alexey Landyrev on 04.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import Foundation
import YandexMobileMetrica
import StoreKit
import Sentry

class Analytics {
    let devMode: Bool
    static let sharedInstance = Analytics()
    
    init() {
        #if IOS_DEBUG
        devMode = true
        #else
        devMode = false
        #endif
    }
    
    func initMetrics() {
        if (!devMode) {
            YMMYandexMetrica.activate(with: .init(apiKey: "73f4540f-a438-4b3b-97f3-2b0f5f452043")!)
        }
        SentrySDK.start { options in
            options.dsn = "https://d3911bc726954b7884fe39d632d5c172@o4505052152004608.ingest.sentry.io/4505052152791040"
            options.tracesSampleRate = 1.0
            if (self.devMode) {
                options.environment = "dev"
            } else {
                options.environment = "production"
            }
        }
    }
    
    func navigate(_ pageName: String, params: [String:Any]?) {
        if (devMode) {
            return
        }
        YMMYandexMetrica.reportEvent("page_opened", parameters: params, onFailure: nil)
        
    }
    
    func event(_ name: String, params: [String:Any]?) {
        if (devMode) {
            NSLog("Message \"\(name)\" sended with params \(params ?? [:])")
        } else {
            YMMYandexMetrica.reportEvent(name, parameters: params, onFailure: nil)
        }
    }
    
    func paidAction(_ product: Product, transactionId: String) {
//        FIRAnalytics.logEvent(withName: kFIREventEcommercePurchase, parameters: [
//            kFIRParameterPrice: product.price,
//            kFIRParameterCurrency: product.priceLocale
//        ])
    }
    
    func captureError(_ error: Error) {
        SentrySDK.capture(error: error)
    }
}
