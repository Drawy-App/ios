//
//  AppLovinBannerLoader.swift
//  htd
//
//  Created by Alexey Landyrev on 08.06.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import AppLovinSDK

class AppLovinBannerLoader: NSObject, BannerAdLoader, MAAdViewAdDelegate, MAAdRevenueDelegate {
    private var retryAttempt: Double = 0
    let id = "16e1ef1bec51c5fc"
    let format = MAAdFormat.mrec
    let height: CGFloat?
    var adView: MAAdView?
    let view: UIView
    
    required init(view: UIView, height: CGFloat?) {
        self.height = height
        self.view = view
        super.init()
    }
    
    func getView(_ rootViewController: UIViewController) -> UIView {
        adView = MAAdView.init(adUnitIdentifier: id, adFormat: format)
        
        adView!.delegate = self
        adView!.revenueDelegate = self
        let frame = view.frame
        let frameHeight = height ?? frame.height
        let frameWidth = view.frame.width
        adView!.frame = CGRect(
            x: 0, y: 0,
            width: frameWidth,
            height: frameHeight
        )
    
        // Center the MREC
        adView!.center.x = view.center.x
    
        // Set background or background color for MREC ads to be fully functional
        adView!.backgroundColor = .clear
    
        view.addSubview(adView!)
    
        // Load the first ad
        adView!.loadAd()
        return adView!
    }
    
    func didExpand(_ ad: MAAd) {
    }
    
    func didCollapse(_ ad: MAAd) {
    }
    
    func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: MAAd) {
    }
    
    func didLoad(_ ad: MAAd) {
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
    }
    
    func didDisplay(_ ad: MAAd) {
        Analytics.sharedInstance.adShown(ad)
    }
    
    func didPayRevenue(for ad: MAAd) {
        Analytics.sharedInstance.revenuePaid(ad)
    }
    
    func didHide(_ ad: MAAd) {
    }
    
    func didClick(_ ad: MAAd) {
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.adView?.loadAd()
        }
    }
    
}
