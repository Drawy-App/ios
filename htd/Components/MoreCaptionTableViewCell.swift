//
//  MoreCaptionTableViewCell.swift
//  htd
//
//  Created by Alexey Landyrev on 04.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class MoreCaptionTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var threeStars: UIImageView!
    var neededStars: Int? = nil
    var maxStars: Int? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
