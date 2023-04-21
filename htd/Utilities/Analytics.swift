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
    
    static let sharedInstance = Analytics()
    
    func initMetrics() {
//        #if IOS_DEBUG
//            YMMYandexMetrica.activate(with: YMMYandexMetricaConfiguration.init(
//                apiKey: "dfc8e1e1-ffc6-46b1-822e-f9c39bb43510")!
//            )
//        #else
//            YMMYandexMetrica.activate(with: YMMYandexMetricaConfiguration.init(
//                apiKey: "73f4540f-a438-4b3b-97f3-2b0f5f452043")!
//            )
//        #endif
//        SentrySDK.start { options in
//            options.dsn = "https://d3911bc726954b7884fe39d632d5c172@o4505052152004608.ingest.sentry.io/4505052152791040"
//            options.tracesSampleRate = 1.0
//            #if IOS_DEBUG
//            options.environment = "dev"
//            #else
//            options.environment = "production"
//            #endif
//        }
    }
    
    func navigate(_ pageName: String, params: [String:Any]?) {
        YMMYandexMetrica.reportEvent("page_opened", parameters: params, onFailure: nil)
        
    }
    
    func event(_ name: String, params: [String:Any]?) {
//        YMMYandexMetrica.reportEvent(name, parameters: params, onFailure: nil)
        #if IOS_DEBUG
            NSLog("Message \"\(name)\" sended with params \(params ?? [:])")
        #endif
    }
    
    func paidAction(_ product: Product, transactionId: String) {
//        FIRAnalytics.logEvent(withName: kFIREventEcommercePurchase, parameters: [
//            kFIRParameterPrice: product.price,
//            kFIRParameterCurrency: product.priceLocale
//        ])
    }
    
    func captureError(_ error: Error) {
//        SentrySDK.capture(error: error)
    }
}
