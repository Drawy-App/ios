//
//  NavigationViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 27.05.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let preferences = UserDefaults.standard
        let lastRun = preferences.integer(forKey: "first_run")
        if (lastRun <= 0) {
            setTutorial()
        }
        #if IOS_DEBUG
        setTutorial()
        #endif
    }
    
    func setTutorial() {
        let rootVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tutorial")
        setViewControllers([rootVC], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
