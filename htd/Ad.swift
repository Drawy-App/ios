//
//  Ad.swift
//  htd
//
//  Created by Aleksey Landyrev on 21.04.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import AppLovinSDK
import AppTrackingTransparency
import AdSupport
import CleverAdsSolutions

enum MediationType {
    case applovin
    case cas
}

class Ad {
    let mediationType = MediationType.cas
    var casMediationManager: CASMediationManager?
    static let sharedInstance = Ad()
    
    var isProMode: Bool {
        return Purchase.sharedInstance.proMode
    }

    var showAd: Bool {
        get {
            return !isProMode
        }
    }

    func initialise() {
        switch mediationType {
        case .applovin:
            ATTrackingManager.requestTrackingAuthorization { status in
                self.initAppLovin()
            }
        case .cas:
            initCas()
        }
    }
    
    func initCas() {
        CAS.settings.setTagged(audience: .notChildren)
        
        casMediationManager = CAS.buildManager()
            // List Ad formats used in app
            .withAdTypes(CASType.banner, CASType.interstitial, CASType.rewarded)
            // Set Test ads or live ads
            .withTestAdMode(Analytics.sharedInstance.devMode)
            .withConsentFlow(.init(isEnabled: true))
            .withCompletionHandler({ initialConfig in
                if let error = initialConfig.error {
                   print("CAS Initialization failed: \(error)")
                } else {
                   print("CAS Initialization completed")
                }
            })
            // Set your CAS ID
            .create(withCasId: "1344514998")
        print("initialised")
    }
    
    func debug() {
        let uid = AdSupport.ASIdentifierManager.shared().advertisingIdentifier.uuidString
        UIPasteboard.general.string = uid
        ALSdk.shared()!.showMediationDebugger()
    }
    
    private func initAppLovin() {

        ALPrivacySettings.setHasUserConsent(true)
        ALPrivacySettings.setIsAgeRestrictedUser(true)
        ALPrivacySettings.setDoNotSell(false)
        let settings = ALSdkSettings()
        let sdk = ALSdk.shared(with: settings)!
        // Please make sure to set the mediation provider value to "max" to ensure proper functionality
        sdk.mediationProvider = "max"
        sdk.initializeSdk { (configuration: ALSdkConfiguration) in
        }
    }
    
    func getBannerLoader(view: UIView, height: CGFloat? = nil) -> BannerAdLoader {
        switch mediationType {
        case .applovin:
            return AppLovinBannerLoader(view: view, height: height)
        case .cas:
            return CASBannerLoader(view: view, height: height)
        }
    }
}
