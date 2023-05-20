//
//  AdViewCell.swift
//  htd
//
//  Created by Aleksey Landyrev on 22.04.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import UIKit
import AppLovinSDK

class AdViewCell: UITableViewCell, MAAdViewAdDelegate, MAAdRevenueDelegate {
    var adView: MAAdView?
    var retryAttempt = 0.0

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadAd()
    }
    
    private func loadAd() {
        adView?.removeFromSuperview()
        adView = MAAdView(adUnitIdentifier: "78322977698178e3")
        adView!.delegate = self
        adView!.revenueDelegate = self

        let view = self.contentView
    
        adView!.frame = view.frame
        adView!.backgroundColor = UIColor.clear
    
        view.addSubview(adView!)
    
        // Load the first ad
        adView!.loadAd()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func didExpand(_ ad: MAAd) { }
    
    func didCollapse(_ ad: MAAd) { }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.adView?.loadAd()
        }
    }
    
    func didDisplay(_ ad: MAAd) {
        Analytics.sharedInstance.adShown(ad)
    }
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { }
    
    func didPayRevenue(for ad: MAAd) {
        Analytics.sharedInstance.revenuePaid(ad)
    }
}
