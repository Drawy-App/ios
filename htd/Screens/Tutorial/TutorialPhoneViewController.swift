//
//  TutorialPhoneViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 26.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class TutorialPhoneViewController: UIViewController {

    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var phoneYConstraint: NSLayoutConstraint!
    @IBOutlet weak var paperImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: UIControl!
    @IBOutlet weak var continueLabel: UILabel!
    private var page = 0
    private var images: [UIImage]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = [
            UIImage.init(named: "paper0")!,
            UIImage.init(named: "paper1")!,
            UIImage.init(named: "paper2")!,
            UIImage.init(named: "paper3")!
        ]
        
        Colorize.sharedInstance.addColor(toView: self.view)
        // Do any additional setup after loading the view.
        
        self.continueButton.addTarget(self, action: #selector(cont), for: .touchUpInside)
        
        startSwiping()
    }
    
    @objc
    func cont() {
        let preferences = UserDefaults.standard
        preferences.set(Date().timeIntervalSince1970, forKey: "first_run")
        preferences.synchronize()
        
        let targetVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "main")
        self.navigationController?.setViewControllers([targetVC], animated: true)

//        performSegue(withIdentifier: "exitTutorial", sender: nil)
    }

    func startSwiping() {
        page = 0
        paperImage.image = images![page]
        self.titleLabel.text = NSLocalizedString("TUTORIAL_DRAW_IMAGES", comment: "TUTORIAL_DRAW_IMAGES")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) -> Void in
            self.page += 1
            if self.page == self.images!.count {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.startAnimate()
                }
                return
            }
            DispatchQueue.main.async {
                self.paperImage.image = self.images![self.page]
            }
            
        })
    }
    
    func startAnimate() {
        self.titleLabel.text = NSLocalizedString("TUTORIAL_USE_NETWORK", comment: "TUTORIAL_DRAW_IMAGES")
        UIView.animate(withDuration: 0.3, animations: {
            self.phoneImage.alpha = 1.0
        })
        self.phoneYConstraint.constant = 100
        UIView.animate(withDuration: 0.75, delay: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(_: Bool) -> Void in
            self.phoneImage.image = UIImage.init(named: "phone")
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false,
                                 block: {_ in
                self.reset()
            })
        })
    }
    
    func reset() {
        self.phoneImage.image = UIImage.init(named: "phone_empty")
        self.phoneYConstraint.constant = 170
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
            self.phoneImage.alpha = 0.25
        }, completion: {(_: Bool) -> Void in
            self.startSwiping()
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
