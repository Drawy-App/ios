//
//  AdViewCell.swift
//  htd
//
//  Created by Aleksey Landyrev on 22.04.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import UIKit

class AdViewCell: UITableViewCell {
    var adView: UIView?
    var retryAttempt = 0.0

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadAd(_ rootViewController: UIViewController) {
        let bannerLoader = Ad.sharedInstance.getBannerLoader(view: self.contentView)
        adView = bannerLoader.getView(rootViewController)
    }
}
