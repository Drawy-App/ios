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

class Ad {
    static let sharedInstance = Ad()

    func initialise() {
        ATTrackingManager.requestTrackingAuthorization { status in
            self.initAppLovin()
        }
    }
    
    private func initAppLovin() {
        let settings = ALSdkSettings()
        let sdk = ALSdk.shared(with: settings)!
        // Please make sure to set the mediation provider value to "max" to ensure proper functionality
        sdk.mediationProvider = "max"
        sdk.initializeSdk { (configuration: ALSdkConfiguration) in
            
        }
    }
}
