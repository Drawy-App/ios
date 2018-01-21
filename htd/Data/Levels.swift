//
//  Levels.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class Levels {
    static var data = [
        Level.init(preview: UIImage.init(
            named: "pug_preview")!, title: "Маленький мопс", duration: 3,
            tutorials: [
                "pug_00",
                "pug_01",
                "pug_02",
                "pug_03",
                "pug_04",
                "pug_05",
                "pug_06",
            ]
        ),
        Level.init(preview: UIImage.init(named: "boat_preview")!, title: "Парусная лодка", duration: 2, tutorials: [])
    ]
}
