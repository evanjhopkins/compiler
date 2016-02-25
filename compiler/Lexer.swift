//
//  Lexer.swift
//  compiler
//
//  Created by Evan Hopkins on 2/23/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Lexer: CompilerComponentProtocol{
    var CLASSNAME = "LEXER"

    let patterns = [
        (name: "IF", pattern: "if"),
        (name: "DIGIT", pattern: "[0-9]"),
        (name: "STRING", pattern: "\"+[a-zA-Z0-9]+\""),
        (name: "PAREN", pattern: "\\(|\\)"),
        (name: "EQUALITY", pattern: "==|!="),
        (name: "SPACE", pattern: " "),
        (name: "ADDITION", pattern: "\\+"),
        (name: "TYPE", pattern: "int|string|boolean"),
        (name: "ADDITION", pattern: "\\+"),
        (name: "CHAR", pattern: "[a-zA-Z]"),
    ]

    func getLexy(input: String) -> [Token]{
        
        var string: String = ""
        var tokens: [Token] = []
        var substr = ""
        var lastMatch: Token?
        var lastInput: String?
        for char in input.characters {
            string = string + String(char)
            //print("\""+string+"\"")
        
            if let matchedToken = matchStringToToken(string) {
                lastMatch = matchedToken
                lastInput = input.substringFromIndex(string.startIndex.advancedBy(string.characters.count))
            }
        }
        
        if (lastMatch != nil){
            tokens.append(lastMatch!)
            Debug.log("\""+lastMatch!.value+"\" --> [" + lastMatch!.type + "]", caller: self)
            tokens += getLexy(lastInput!)
            return tokens
        }
        
        if(input.characters.count > 0 ) {
            substr = string.substringFromIndex(string.startIndex.advancedBy(1))
            Debug.error("Unrecognized Token: "+String(input.characters.first!), caller: self)
            tokens += getLexy(substr)
        }

        return tokens
    }
    
    private func matchStringToToken(string: String) -> Token?{
        //print("\""+string+"\"")
        for pattern in patterns {
            if string.rangeOfString(pattern.pattern, options: .RegularExpressionSearch) == string.characters.indices {
                return Token(value: string, type: pattern.name)
            }
        }
        return nil
    }
}