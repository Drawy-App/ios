//
//  Analytics.swift
//  htd
//
//  Created by Alexey Landyrev on 04.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import Foundation
import Fabric
import Crashlytics
import YandexMobileMetrica

class Analytics {
    
    static let sharedInstance = Analytics()
    
    func initMetrics() {
        Fabric.with([Crashlytics.self])
        #if IOS_DEBUG
            YMMYandexMetrica.activate(withApiKey: "dfc8e1e1-ffc6-46b1-822e-f9c39bb43510")
        #else
            YMMYandexMetrica.activate(withApiKey: "73f4540f-a438-4b3b-97f3-2b0f5f452043")
        #endif
    }
    
    func navigate(_ pageName: String, params: [String:Any]?) {
        self.event("page_opened", params: [pageName: params ?? [:]])
    }
    
    func event(_ name: String, params: [String:Any]?) {
        YMMYandexMetrica.reportEvent(name, parameters: params, onFailure: nil)
        #if IOS_DEBUG
            NSLog("Message \"\(name)\" sended with params \(params ?? [:])")
        #endif
    }
}
