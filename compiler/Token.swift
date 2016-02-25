//
//  Token.swift
//  compiler
//
//  Created by Evan Hopkins on 2/23/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Token {

    var value: String
    var type: String
    var lineNum: Int
    
    init(value: String, type: String) {
        self.value = value
        self.type = type
        lineNum = 0
    }
    
    func extend(extendee: String) {
        value = value + extendee
    }
    
}