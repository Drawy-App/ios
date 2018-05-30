//
//  FirstImageViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 27.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class FirstImageViewController: UIViewController {

    @IBOutlet weak var backButton: UIControl!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var recognizeButton: UIControl!
    @IBOutlet weak var recognizeLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.recognizeButton.layer.cornerRadius = 5
        self.recognizeButton.addTarget(self, action: #selector(recognize), for: .touchUpInside)
        
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "")
        recognizeLabel.text = NSLocalizedString("CHECK_BUTTON", comment: "")
        
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        Colorize.sharedInstance.addColor(toView: self.view)
        
    }

    @objc
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func recognize() {
        performSegue(withIdentifier: "recognizeFromFirst", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! RecognizerViewController
        dest.level = Levels.sharedInstance.stages[0]!.levels[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
