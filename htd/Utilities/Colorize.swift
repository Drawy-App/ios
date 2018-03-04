//
//  Colorize.swift
//  htd
//
//  Created by Alexey Landyrev on 04.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class Colorize {
    
    static let sharedInstance = Colorize()
    
    static let pattenrNames = [
        "pattern1",
        "pattern2",
        "pattern3"
    ]
    let patternName: String
    
    func addColor(toView view: UIView) {
        let color = UIColor.init(patternImage: UIImage.init(named: patternName)!)
        let newView = UIView.init(frame: view.frame)
        newView.backgroundColor = color
        newView.layer.opacity = 0.15
        view.layer.insertSublayer(newView.layer, at: 0)
    }
    
    init() {
        patternName = Colorize.pattenrNames[Int(
            arc4random_uniform(
                UInt32(Colorize.pattenrNames.count - 1)
            ) + 1
        )]
    }
}
