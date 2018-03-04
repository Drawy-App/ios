//
//  LevelsTableViewCell.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class LevelsTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var starsOuterView: UIView!
    
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
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cellView.layer.cornerRadius = 5
        
        cellView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowRadius = 0
    }

    func updateLevel() {
        title.text = level!.title
        for view in starsOuterView.subviews {
            view.removeFromSuperview()
        }
        for i in 0...(level!.difficulty - 1) {
            addStar(i, full: level!.rating > 0 )
        }
    }
    
    func addStar(_ number: Int, full: Bool) {
        let imageView = UIImageView.init()
        imageView.frame = .init(x: number * (16 + 4), y: 7, width: 16, height: 16)
        self.starsOuterView.addSubview(imageView)
        imageView.image = UIImage.init(named: full ? "star" : "star_empty")
    }

}
