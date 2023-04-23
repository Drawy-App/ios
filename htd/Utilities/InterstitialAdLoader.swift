//
//  InterstitialAdLoader.swift
//  htd
//
//  Created by Aleksey Landyrev on 22.04.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import AppLovinSDK

class InterstitialAdLoader: NSObject, MAAdDelegate {
    private let adId: String
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0

    var onHideCallback: (() -> Void)?
    
    init(adId: String) {
        self.adId = adId
        super.init()
        interstitialAd = MAInterstitialAd(adUnitIdentifier: adId)
        interstitialAd.delegate = self

        // Load the first ad
        interstitialAd.load()
    }
    
    func maybeShowAdWith(callback: @escaping (() -> Void)) {
        self.onHideCallback = callback
        if (interstitialAd.isReady) {
            interstitialAd.show()
        } else {
            runCallback()
        }
    }
    
    func runCallback() {
        self.onHideCallback?()
        self.onHideCallback = nil
    }

    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.interstitialAd.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) {
    }
    
    func didHide(_ ad: MAAd) {
        runCallback()
        interstitialAd.load()
    }
    
    func didClick(_ ad: MAAd) {
        runCallback()
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        runCallback()
        interstitialAd.load()
    }
    
    
}
