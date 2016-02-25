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
    var type: TokenType
    //not tracking line num yet
    var line: Int = 0
    
    init(value: String, type: TokenType) {
        self.value = value
        self.type = type
    }
    
    func isType(type: TokenType) -> Bool {
        if self.type == type{
            return true
        }
        return false
    }

}

enum TokenType{
    case LBRACE
    case RBRACE
    case DIGIT
    case CHAR
    case IF
    case WHILE
    case STRING
    case PRINT
    case LPAREN
    case RPAREN
    case SPACE
    case BOOLOP
    case INTOP
    case TYPE
}