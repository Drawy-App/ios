//
//  TutorialPhoneViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 26.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import Firebase

class TutorialPhoneViewController: UIViewController {

    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var paperImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: UIControl!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var phoneYConstraint: NSLayoutConstraint!
    
    var startTime: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Colorize.sharedInstance.addColor(toView: self.view)
        // Do any additional setup after loading the view.
        
        self.continueButton.layer.cornerRadius = 5
        self.continueButton.addTarget(self, action: #selector(cont), for: .touchUpInside)
        self.continueLabel.text = NSLocalizedString("CONTINUE_BUTTON", comment: "")
        self.titleLabel.text = NSLocalizedString("TUTORIAL_USE_NETWORK", comment: "TUTORIAL_DRAW_IMAGES")
        
        startTime = Date()
        Analytics.sharedInstance.event("tutorial_page_2_opened", params: nil)
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {_ in
            self.startAnimate()
        })

    }
    
    @objc
    func cont() {
        UserInfo.initFirstRun()
        
        let timeElapsed: Double = Date().timeIntervalSince(startTime!)
        Analytics.sharedInstance.event("tutorial_page_2_passed", params: [
            "time_elapsed": Int(timeElapsed)
            ])
        Analytics.sharedInstance.event(kFIREventTutorialComplete, params: [
            "time_elapsed": Int(timeElapsed)
            ])
        
        let targetVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        self.navigationController?.setViewControllers([targetVC], animated: true)
    }
    
    func startAnimate() {
        self.phoneYConstraint.constant = -100
        
        UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(_: Bool) -> Void in
            self.phoneImage.image = UIImage.init(named: "phone")
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false,
                                 block: {_ in
                self.reset()
            })
        })
    }
    
    func reset() {
        self.phoneImage.image = UIImage.init(named: "phone_empty")
        self.phoneYConstraint.constant = -170
        UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(_: Bool) -> Void in
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
                self.startAnimate()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
