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
    @IBOutlet weak var unlockAllButton: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var threeStars: UIImageView!
    var navigationController: UINavigationController? = nil
    var neededStars: Int? = nil
    var maxStars: Int? = nil
    var section: Int? = nil
    var onTap: (() -> Void)? = nil;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    @objc
    func gotoPayWall() {
        self.onTap!()
    }
    
    
    func update() {
        
        let share = Int(100 * Float(maxStars! - neededStars!) / Float(maxStars!))
        if share >= 66 {
            self.threeStars.image = UIImage.init(named: "three_stars_two")!
        } else if share >= 33 {
            self.threeStars.image = UIImage.init(named: "three_stars_one")!
        } else {
            self.threeStars.image = UIImage.init(named: "three_stars_zero")!
        }
        
        self.buttonLabel.text = NSLocalizedString(
            "UNLOCK_ALL_LEVELS",
            comment: "Unlock all levels button"
        )
        
        if self.section == 1 {
            self.unlockAllButton.isHidden = true
            self.threeStars.isHidden = true
            self.captionLabel.text = NSLocalizedString("NEED_TO_FINISH_TEST", comment: "")
        } else if self.section == 2 || UserInfo.isOldFreeVersion {
            self.captionLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("NEED_MORE_STARS", comment: "Need more stars"),
                neededStars!
            )
        } else {
            self.threeStars.isHidden = true
            self.captionLabel.text = NSLocalizedString("BUY_TEASER", comment: "Buy teaser for header")
        }
        
        let buttonRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoPayWall))
        self.unlockAllButton.addGestureRecognizer(buttonRecognizer)
        self.unlockAllButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
