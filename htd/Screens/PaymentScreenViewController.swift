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
    var analyticsParams: [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsParams = [
            "levelsUnlockedCount": Levels.sharedInstance.unlockedLevels
        ]
        
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "Back button")
        self.buyButtonLabel.text = NSLocalizedString("PAY_BUTTON_NO_PRICE", comment: "Pay button no price")
        self.adwLabel.text = NSLocalizedString("BUY_DESCRIPTION", comment: "Buy description")
        
        self.payButtonView.layer.cornerRadius = 5
        self.payButtonView.isUserInteractionEnabled = true
        self.proModeTitle.text = NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode title").uppercased()
        
        self.buyButtonTap.addTarget(self, action: #selector(tryToPay))
        
        prepare()
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
    
    func switchButton(_ isEnabled: Bool) {
        self.payButtonView.alpha = isEnabled ? 1 : 0.5
        if isEnabled {
            self.buyButtonTap.addTarget(self, action: #selector(tryToPay))
        } else {
            self.buyButtonTap.removeTarget(self, action: #selector(tryToPay))
        }
        self.throbberView.isHidden = isEnabled
    }
    
    @objc func tryToPay() {
        Analytics.sharedInstance.event("pay_init", params: self.analyticsParams)
        switchButton(false)
        Purchase.sharedInstance.purchase(Purchase.unlockAllId, callback: {is_success, error in
            self.switchButton(true)
            if error == nil {
                Analytics.sharedInstance.event("pay_success", params: self.analyticsParams)
                let alert = UIAlertController.init(
                    title: "\(NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode")) 👑",
                    message: NSLocalizedString("PAID_SUCCESS_POPUP", comment: "Pay success popup"),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction.init(
                    title: NSLocalizedString("CONTINUE_BUTTON", comment: "Continue button"),
                    style: .default, handler: {_ in
                        alert.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                ))
                self.present(alert, animated: true, completion: nil)
            } else {
                var error_params = self.analyticsParams
                error_params["error"] = error.debugDescription
                Analytics.sharedInstance.event("pay_failure", params: error_params)
                
                let alert = UIAlertController.init(
                    title: NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode"),
                    message: error!.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {_ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
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

    override func viewWillAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("pay_wall", params: self.analyticsParams)
    }

}
