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
    let debug = Debug.sharedInstance
    var tokens: [Token]
    
    init () {
        self.tokens = [Token]()
    }
    
    let patterns:[(type: TokenType, pattern: String)] = [
        (TokenType.IF, "if"),
        (TokenType.DIGIT, "[0-9]"),
        (TokenType.STRING, "\"+[a-zA-Z0-9 ]*+\""),
        (TokenType.PRINT, "print"),
        (TokenType.LPAREN, "\\("),
        (TokenType.RPAREN, "\\)"),
        (TokenType.BOOLOP, "==|!="),
        (TokenType.BOOLVAL, "true|false"),
        (TokenType.SPACE, " |^\n|\\t"),
        (TokenType.INTOP, "\\+"),
        (TokenType.TYPE, "int|string|boolean"),
        (TokenType.CHAR, "[a-zA-Z]"),
        (TokenType.WHILE, "while"),
        (TokenType.LBRACE, "\\{"),
        (TokenType.RBRACE, "\\}"),
        (TokenType.ASSIGN, "="),
        (TokenType.EOL, "\\$")
    ]
    
    func lex(input: String) -> Bool {
        debug.log("Lexing...", caller: self)
        let lexerStart = NSDate().timeIntervalSince1970 //mark time when lexer starts
        let lexSucceeded = getLexy(input)
        let lexerStop = NSDate().timeIntervalSince1970 //mark time when lexer completes
        let executionTime = lexerStop - lexerStart
        
        if lexSucceeded {
            debug.affirm("Lex completed, "+String(executionTime)+"s", caller: self)
            return true
        }
        debug.error("Lex failed, "+String(executionTime)+"s", caller: self)
        return false
    }
    
    func getTokens() -> [Token] {
        return self.tokens
    }
    
    private func getLexy(input: String) -> Bool{
        
        var string: String = ""
        var lastMatch: Token?
        var lastInput: String?
        
        for char in input.characters {
            string = string + String(char)
        
            if let matchedToken = matchStringToToken(string) {
                lastMatch = matchedToken
                lastInput = input.substringFromIndex(string.startIndex.advancedBy(string.characters.count))
            }
        }
        
        if (lastMatch != nil){
            if (!lastMatch!.isType(TokenType.SPACE)){
                //ignore space
                self.tokens.append(lastMatch!)
            }
            //throw out white space
            if lastMatch!.type != TokenType.SPACE {
                debug.log("\""+lastMatch!.value+"\" --> [" + String(lastMatch!.type) + "]", caller: self)
            }
            return getLexy(lastInput!)
        }
        
        if(input.characters.count > 0 ) {
            debug.error("Unrecognized Token: "+String(input.characters.first!), caller: self)
            return false
        }

        return true
    }
    
    private func matchStringToToken(string: String) -> Token?{
        for pattern in patterns {
            if string.rangeOfString(pattern.pattern, options: .RegularExpressionSearch) == string.characters.indices {
                return Token(value: string, type: pattern.type)
            }
        }
        return nil
    }
}