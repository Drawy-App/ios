//
//  PaymentScreenViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 05.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import StoreKit
import Crashlytics

class PaymentScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var proModeTitle: UILabel!
    @IBOutlet weak var adwLabel: UILabel!
    @IBOutlet weak var buyButtonLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet weak var payButtonView: UIView!
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet var buyButtonTap: UITapGestureRecognizer!
    @IBOutlet var backButtonTap: UITapGestureRecognizer!
    @IBOutlet weak var throbberView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "Back button")
        self.buyButtonLabel.text = NSLocalizedString("PAY_BUTTON_NO_PRICE", comment: "Pay button no price")
        self.adwLabel.text = NSLocalizedString("BUY_DESCRIPTION", comment: "Buy description")
        
        self.payButtonView.layer.cornerRadius = 5
        self.payButtonView.isUserInteractionEnabled = true
        self.proModeTitle.text = NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode title")
        
        prepare()
        // Do any additional setup after loading the view.
        Colorize.sharedInstance.addColor(toView: self.view)
    }
    
    func prepare() {
        self.throbberView.startAnimating()
        Purchase.sharedInstance.retrieveInfo(Purchase.unlockAllId, callback: {product, error in
            if product != nil {
                print("product", product!.productIdentifier)
                self.enablePay(product!)
            } else {
                print("error", error!.localizedDescription)
                self.exit()
            }
        })
    }
    
    func enablePay(_ product: SKProduct) {
        DispatchQueue.main.async {
            self.payButtonView.alpha = 1
            self.buyButtonLabel.text = String.init(
                format: NSLocalizedString("PAY_BUTTON", comment: "Buy button"), product.localizedPrice!
            )
            self.throbberView.isHidden = true
            self.backButtonView.layer.opacity = 1
            self.backButtonTap.addTarget(self, action: #selector(self.exit))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func exit() {
        self.dismiss(animated: true, completion: nil)
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
