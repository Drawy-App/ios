//
//  Level.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class Level {
    var preview: UIImage
    var title: String
    var duration: Int
    
    init(preview: UIImage, title: String, duration: Int) {
        self.preview = preview
        self.title = title
        self.duration = duration
    }
}
