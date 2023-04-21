//
//  TutorialFirstViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 27.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class TutorialFirstViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var continueButton: UIControl!
    @IBOutlet weak var continueLabel: UILabel!
    var startTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTime = Date()
        
        continueButton.layer.cornerRadius = 5
        continueLabel.text = NSLocalizedString("CONTINUE_BUTTON", comment: "")
        continueButton.addTarget(self, action: #selector(cont), for: .touchUpInside)
        
        self.textLabel.text = NSLocalizedString("TUTORIAL_ALL_YOU_NEED", comment: "All you need is")
        
        Colorize.sharedInstance.addColor(toView: self.view)
        
        Analytics.sharedInstance.event("tutorial_begin", params: nil)
        Analytics.sharedInstance.event("tutorial_page_1_opened", params: nil)
    }
    
    @objc
    func cont() {
        let timeElapsed: Double = Date().timeIntervalSince(startTime!)
        Analytics.sharedInstance.event("tutorial_page_0_passed", params: [
            "time_elapsed": Int(timeElapsed)
            ])
        performSegue(withIdentifier: "firstToNextTutorial", sender: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
