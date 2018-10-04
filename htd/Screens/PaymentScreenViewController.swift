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
    @IBOutlet weak var restoreButton: UIButton!
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
        self.restoreButton.setTitle(NSLocalizedString("RESTORE_BUTTON", comment: "Restore button"), for: .normal)
        self.backButtonTap.addTarget(self, action: #selector(self.exit))
        self.buyButtonLabel.text = NSLocalizedString("PAY_BUTTON_NO_PRICE", comment: "Pay button no price")
        self.adwLabel.text = NSLocalizedString("BUY_DESCRIPTION", comment: "Buy description")
        
        self.payButtonView.layer.cornerRadius = 5
        self.payButtonView.isUserInteractionEnabled = true
        self.proModeTitle.text = NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode title").uppercased()
        
        self.restoreButton.addTarget(self, action: #selector(self.restore), for: .touchUpInside)
        
        prepare()
        Colorize.sharedInstance.addColor(toView: self.view)
    }
    
    func prepare() {
        switchButton(false)
        Purchase.sharedInstance.retrieveInfo(Purchase.unlockAllId, callback: {product, error in
            if product != nil {
                print("product", product!.productIdentifier)
                self.enablePay(product!)
            } else {
                print("error", error?.localizedDescription)
                self.exit()
            }
        })
    }
    
    func switchButton(_ isEnabled: Bool) {
        self.payButtonView.alpha = isEnabled ? 1 : 0.5
        self.restoreButton.alpha = isEnabled ? 1 : 0.5
        self.restoreButton.isEnabled = isEnabled
        if isEnabled {
            self.throbberView.stopAnimating()
            self.buyButtonTap.addTarget(self, action: #selector(tryToPay))
        } else {
            self.throbberView.startAnimating()
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
                self.onSuccess()
            } else {
                self.onFail(error, description: error!.localizedDescription)
            }
        })
    }
    
    @objc func restore() {
        self.switchButton(false)
        Purchase.sharedInstance.restore(Purchase.unlockAllId, callback: {success, error in
            self.switchButton(true)
            if success {
                self.onSuccess(isRestore: true)
            } else {
                self.onFail(
                    error, description: NSLocalizedString("ON_RESTORE_FAILED", comment: "On restore failed"),
                    isRestore: true
                )
            }
        })
    }
    
    func onSuccess(isRestore: Bool = false) {
        Analytics.sharedInstance.event(
            isRestore ? "restore_success" : "pay_success", params: self.analyticsParams
        )
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
    }
    
    func onFail(_ error: Error?, description: String, isRestore: Bool = false) {
        var error_params = self.analyticsParams
        error_params["error"] = error.debugDescription
        Analytics.sharedInstance.event(
            isRestore ? "restore_failure" : "pay_failure", params: error_params
        )
        
        let alert = UIAlertController.init(
            title: NSLocalizedString("PRO_MODE_TITLE", comment: "Pro mode"),
            message: description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func enablePay(_ product: SKProduct) {
        DispatchQueue.main.async {
            self.switchButton(true)
            self.buyButtonLabel.text = String.init(
                format: NSLocalizedString("PAY_BUTTON", comment: "Buy button"), product.localizedPrice!
            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func exit() {
//        self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("pay_wall", params: self.analyticsParams)
    }

}
