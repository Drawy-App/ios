//
//  SuccessScreenViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 01.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import StoreKit

class SuccessScreenViewController: UIViewController {

    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet var continueTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var continueButton: UIView!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    var level: Level?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Colorize.sharedInstance.addColor(toView: self.view)
        
        self.textLabel.text = String.init(repeating: "⭐ ", count: level!.difficulty)
        self.subTextLabel.text = NSLocalizedString("SUCCESS_SUB_LABEL", comment: "Success label")
        self.continueLabel.text = NSLocalizedString("CONTINUE_BUTTON", comment: "Continue")
        self.continueButton.layer.cornerRadius = 5
        self.continueTapGesture.addTarget(self, action: #selector(exit))
    }
    
    @objc func rateUs() {
        if (UserInfo.mayRate()) {
            SKStoreReviewController.requestReview()
            UserInfo.setRateTimeout()
        }
    }
    
    @objc func exit() {
        self.rateUs()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("success", params: ["name": self.level!.name])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
