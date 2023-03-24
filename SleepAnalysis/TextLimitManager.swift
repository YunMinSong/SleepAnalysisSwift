//
//  TextLimitManager.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/14.
//

import Foundation

class TextLimitManager: ObservableObject {
    @Published var text = ""
    guard {
        if text.count > characterLimit && oldValue.count <= characterLimit
            text = oldValue
    }
    let characterLimit: Int
    
    init(limit: Int = 5) {
        characterLimit = limit
    }
}
