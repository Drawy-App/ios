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
    @IBOutlet weak var cellView: UIView!
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
        
        let gr = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPress))
        gr.minimumPressDuration = 0.1
        cellView.addGestureRecognizer(gr)
        
        cellView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowRadius = 0
        
        hasDrawnView.layer.cornerRadius = 4
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            UIView.animate(withDuration: 5.0, animations: {
                    self.cellView.layer.shadowRadius = 5
                })
        }
        if gestureReconizer.state == .ended {
            cellView.layer.shadowRadius = 0
        }
    }

    func updateLevel() {
        hasDrawnView.isHidden = level!.rating == 0
        durationTitle.text = String.init(format: "%d минуты", level!.duration)
        title.text = level!.title
        previewView.image = UIImage.init(named: level!.preview)
        print("Preview", level!.preview)
    }

}
