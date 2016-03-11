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
    var VERBOSE = true
    let debug = Debug.sharedInstance
    
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
    
    func lex(input: String) -> [Token] {
        let tokens: [Token] = getLexy(input)
        debug.affirm("Lex completed successfully", caller: self)
        return tokens
    }
    private func getLexy(input: String) -> [Token]{
        
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
            if (!lastMatch!.isType(TokenType.SPACE)){
                //ignore space
                tokens.append(lastMatch!)
            }
            //throw out white space
            if lastMatch!.type != TokenType.SPACE {
                debug.log("\""+lastMatch!.value+"\" --> [" + String(lastMatch!.type) + "]", caller: self)
                if lastMatch!.type == TokenType.EOL {
                    print("")//line break to seperate programs in lex output
                }
            }
            tokens += getLexy(lastInput!)
            return tokens
        }
        
        if(input.characters.count > 0 ) {
            substr = string.substringFromIndex(string.startIndex.advancedBy(1))
            debug.error("Unrecognized Token: "+String(input.characters.first!), caller: self)
            tokens += getLexy(substr)
        }

        return tokens
    }
    
    private func matchStringToToken(string: String) -> Token?{
        //print("\""+string+"\"")
        for pattern in patterns {
            if string.rangeOfString(pattern.pattern, options: .RegularExpressionSearch) == string.characters.indices {
                return Token(value: string, type: pattern.type)
            }
        }
        return nil
    }
}