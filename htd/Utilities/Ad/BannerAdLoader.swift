//
//  BannerAdLoader.swift
//  htd
//
//  Created by Alexey Landyrev on 08.06.2023.
//  Copyright © 2023 Alexey Landyrev. All rights reserved.
//

import Foundation
import UIKit

protocol BannerAdLoader {
    init(view: UIView, height: CGFloat?)
    
    func getView(_ rootViewController: UIViewController) -> UIView
}
