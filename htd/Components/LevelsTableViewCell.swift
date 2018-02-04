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
    @IBOutlet weak var hasDrawnView: UIView!
    @IBOutlet weak var hasDrownLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    var indexPath: IndexPath?
    var tableView: UITableView?
    private var _level: Level?
    var level: Level? {
        set {
            _level = newValue
            if newValue != nil {
                updateLevel()
            }
        }
        get {
            return _level
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hasDrownLabel.text = NSLocalizedString("HAS_DROWN_LABEL", comment: "Has drown label")
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cellView.layer.cornerRadius = 5
        
        cellView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowRadius = 0
        
        hasDrawnView.layer.cornerRadius = 4
    }

    func updateLevel() {
        hasDrawnView.isHidden = level!.rating == 0
        durationTitle.text = GramCase.getLocalizedString(number: level!.tutorials.count, key: "STEPS")
        title.text = NSLocalizedString(level!.name, comment: "Level name")
        previewView.image = UIImage.init(named: level!.preview)
    }

}
