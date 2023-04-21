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

class Analytics {
    
    static let sharedInstance = Analytics()
    
    func initMetrics() {
        #if IOS_DEBUG
            YMMYandexMetrica.activate(with: YMMYandexMetricaConfiguration.init(
                apiKey: "dfc8e1e1-ffc6-46b1-822e-f9c39bb43510")!
            )
        #else
            YMMYandexMetrica.activate(with: YMMYandexMetricaConfiguration.init(
                apiKey: "73f4540f-a438-4b3b-97f3-2b0f5f452043")!
            )
        #endif
    
    }
    
    func navigate(_ pageName: String, params: [String:Any]?) {
        YMMYandexMetrica.reportEvent("page_opened", parameters: params, onFailure: nil)
//        FIRAnalytics.setScreenName(pageName, screenClass: nil)
//        FIRAnalytics.logEvent(withName: "page_opened", parameters: params)
//        AppEventsLogger.log("page_opened", parameters: pa, valueToSum: <#T##Double?#>, accessToken: <#T##AccessToken?#>)
//        AppEventsLogger.log(pageName, parameters: AppEvent.ParametersDictionary.init(uniqueKeysWithValues: params), valueToSum: nil, accessToken: nil)
        
    }
    
    func event(_ name: String, params: [String:Any]?) {
//        FIRAnalytics.logEvent(withName: name, parameters: params)
        YMMYandexMetrica.reportEvent(name, parameters: params, onFailure: nil)
        #if IOS_DEBUG
            NSLog("Message \"\(name)\" sended with params \(params ?? [:])")
        #endif
    }
    
    func paidAction(_ product: SKProduct, transactionId: String) {
//        FIRAnalytics.logEvent(withName: kFIREventEcommercePurchase, parameters: [
//            kFIRParameterPrice: product.price,
//            kFIRParameterCurrency: product.priceLocale
//        ])
    }
}
