//
//  GramCase.swift
//  htd
//
//  Created by Alexey Landyrev on 03.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import Foundation

class GramCase {
    
    enum Cases {
        case nomSingle
        case nomMulti
        case genMulti
    }
    
    static func getCase(_ n: Int) -> Cases {
        let rn = n % 100
        
        if rn == 1 {
            return Cases.nomSingle
        }
        if (2...4).contains(rn) {
            return Cases.nomSingle
        }
        if (5...20).contains(rn) {
            return Cases.genMulti
        }
        return GramCase.getCase(rn % 10)
    }
    
    static func getKey(number: Int, key: String) -> String {
        let cs = getCase(number)
        switch cs {
        case .nomSingle:
            return "\(key)_NS"
        case .nomMulti:
            return "\(key)_NM"
        case .genMulti:
            return "\(key)_GM"
        }
    }
    
    static func getLocalizedString(number: Int, key: String) -> String {
        let casedKey = getKey(number: number, key: key)
        return "\(number) \(NSLocalizedString(casedKey, comment: ""))"
    }
}
