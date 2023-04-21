//
//  TutorialSecondViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 27.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class TutorialSecondViewController: UIViewController {

    @IBOutlet weak var continueButton: UIControl!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var images: [UIImage]?
    var page = 0
    var startTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.addTarget(self, action: #selector(cont), for: .touchUpInside)
        self.continueLabel.text = NSLocalizedString("CONTINUE_BUTTON", comment: "")
        self.textLabel.text = NSLocalizedString("TUTORIAL_DRAW_IMAGES", comment: "TUTORIAL_DRAW_IMAGES")
        continueButton.layer.cornerRadius = 5
        startTime = Date()
        
        Colorize.sharedInstance.addColor(toView: self.view)
        
        images = [
            UIImage.init(named: "composition0")!,
            UIImage.init(named: "composition1")!,
            UIImage.init(named: "composition2")!,
            UIImage.init(named: "composition3")!
        ]
        startSwiping()
        // TODO: Analytics
        // Analytics.sharedInstance.event("tutorial_page_1_opened", params: nil)
    }
    
    func startSwiping() {
        page = 0
        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true, block: {(timer) -> Void in
            self.page += 1
            if (self.page == self.images!.count) {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false, block: {(timer) -> Void in
                    self.startSwiping()
                })
                return
            }
            self.imageView.image = self.images![self.page]
        })
    }
    
    @objc
    func cont() {
        performSegue(withIdentifier: "secondToNextTutorial", sender: nil)
        let timeElapsed: Double = Date().timeIntervalSince(startTime!)
        // TODO: Analytics
//        Analytics.sharedInstance.event("tutorial_page_1_passed", params: [
//            "time_elapsed": Int(timeElapsed)
//            ])
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
