//
//  GalleryCollectionViewCell.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var counterContainer: UIView!
    @IBOutlet weak var counterLabel: UILabel!
    var number: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        previewContainer.layer.cornerRadius = 5
        counterContainer.layer.cornerRadius = 3
    }

}
