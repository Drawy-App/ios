//
//  LevelsTableViewCell.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class LevelsTableViewCell: UITableViewCell {

    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var cellView: UIView!
    var level: Level?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cellView.layer.cornerRadius = 5
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        durationTitle.text = String.init(format: "%d минуты", level!.duration)
        title.text = level!.title
        previewView.image = level!.preview
    }

}
