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

class AdViewCell: UITableViewCell, MAAdViewAdDelegate {
    var adView: MAAdView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadAd()
    }
    
    private func loadAd() {
        adView?.removeFromSuperview()
        adView = MAAdView(adUnitIdentifier: "78322977698178e3")
        adView!.delegate = self

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
    
    func didLoad(_ ad: MAAd) { }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { }
}
