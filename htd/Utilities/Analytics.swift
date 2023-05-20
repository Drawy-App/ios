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
import BranchSDK
import Adjust
import AppLovinSDK

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
    
    func event(_ name: String, params: [String:Any]?, revenue: Double? = nil) {
        if (devMode) {
            NSLog("Message \"\(name)\" sended with params \(params ?? [:])")
        } else {
            YMMYandexMetrica.reportEvent(name, parameters: params, onFailure: nil)
            branchEevent(name, params: params, revenue: revenue)
            adjustEvent(name, params: params, revenue: revenue)
        }
    }
    
    func branchEevent(_ name: String, params: [String:Any]?, revenue: Double? = nil) {
        let branchEvent = BranchEvent.customEvent(withName: name)
        if (params != nil) {
            params!.keys.forEach { key in
                if let value = params![key] {
                    branchEvent.customData[key] = String.init(describing: value)
                }
            }
        }
        branchEvent.logEvent()
    }
    
    func adjustEvent(_ name: String, params: [String: Any]?, revenue: Double? = nil) {
        let event = ADJEvent(eventToken: name)
        if (params != nil) {
            params!.keys.forEach { key in
                if let value = params![key] {
                    event?.addPartnerParameter(key, value: String.init(describing: value))
                }
            }
        }
        if (revenue != nil) {
            event?.setRevenue(revenue!, currency: "USD")
        }
        Adjust.trackEvent(event)
    }
    
    func paidAction(_ product: Product, transactionId: String) {
        branchEevent(BranchStandardEvent.purchase.rawValue, params: [
            "price": product.price,
            "currency": product.priceFormatStyle.currencyCode
        ])
    }
    
    func adShown(_ ad: MAAd) {
        event(
            "ad_shown",
            params: describe(ad: ad) as [String : Any]
        )
    }
    
    func revenuePaid(_ ad: MAAd) {
        event(
            "ad_revenue_paid",
            params: describe(ad: ad) as [String : Any],
            revenue: ad.revenue
        )
    }
    
    func describe(ad: MAAd) -> [String: String?] {
        return [
            "network": ad.networkName,
            "dspName": ad.dspName,
            "dspIdentifier": ad.dspIdentifier,
            "placement": ad.placement,
            "networkPlacement": ad.networkPlacement
        ]
    }
    
    func captureError(_ error: Error) {
        SentrySDK.capture(error: error)
    }
}
