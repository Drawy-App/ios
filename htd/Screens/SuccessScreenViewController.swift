//
//  SuccessScreenViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 01.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class SuccessScreenViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    var level: Level?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Colorize.sharedInstance.addColor(toView: self.view)
        
        self.textLabel.text = NSLocalizedString("SUCCESS_LABEL", comment: "Success label")
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
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
