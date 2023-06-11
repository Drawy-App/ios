//
//  CASBannerLoader.swift
//  htd
//
//  Created by Alexey Landyrev on 08.06.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import UIKit
import CleverAdsSolutions

class CASBannerLoader: NSObject, BannerAdLoader, CASBannerDelegate {
    let height: CGFloat?
    let view: UIView
    
    required init(view: UIView, height: CGFloat?) {
        self.view = view;
        self.height = height
        super.init()
    }
    
    func getView(_ rootViewController: UIViewController) -> UIView {
        let bannerView = CASBannerView(adSize: .mediumRectangle, manager: Ad.sharedInstance.casMediationManager!)
        bannerView.adDelegate = self
        bannerView.rootViewController = rootViewController
//        bannerView.translatesAutoresizingMaskIntoConstraints = true
//
//        let frame = view.frame
//        let frameHeight = height ?? frame.height
//        let frameWidth = view.frame.width
//        bannerView.isAutoloadEnabled = true
//        bannerView.frame = CGRect(
//            x: 0, y: 0,
//            width: frameWidth,
//            height: frameHeight
//        )
//
//         Center the MREC
        bannerView.center.x = view.center.x
        bannerView.backgroundColor = .red
        
        view.addSubview(bannerView)
        print("Banner ad view initialised: \(bannerView.isAdReady)")

        return bannerView
    }
    
    func positionBannerAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Centered horizontally.
        let guide: UILayoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate(
          [bannerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
           bannerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)]
        )
    }
    
    func bannerAdView(_ adView: CASBannerView, didFailWith error: CASError) {
        print("Failed to load banner ad view: \(error)")
    }
    
    func bannerAdViewDidLoad(_ view: CASBannerView) {
        print("Banner ad view loaded")
    }
    
    func bannerAdView(_ adView: CASBannerView, willPresent impression: CASImpression) {
        print("Banner ad view will present")
    }
    
    func bannerAdViewDidRecordClick(_ adView: CASBannerView) {
        print("Banner ad view did record click")
    }
    
}
