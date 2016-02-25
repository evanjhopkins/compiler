//
//  Parser.swift
//  compiler
//
//  Created by Evan Hopkins on 2/24/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Parser: CompilerComponentProtocol {
    var CLASSNAME = "PARSER"
    
    let tokenManager: TokenManager
    
    init(tokenss: [Token]) {
        self.tokenManager = TokenManager(tokens: tokenss)
    }
    
    func parse() {
        parseBlock()
    }
    
    func parseBlock() {
        var token = tokenManager.peekNextToken()
        if token.isType(TokenType.LBRACE) {
            //consume "{"
            tokenManager.consumeNextToken()
        }else{
            Debug.error("Invalid block, no opening brace", caller: self)
        }
        
        parseStatementList()
        
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.RBRACE) {
            //consume "{"
            tokenManager.consumeNextToken()
        }else{
            Debug.error("Invalid block, no closing brace", caller: self)
        }
        
    }
    
    func parseStatementList() {
        parseStatementList(0)
    }
    func parseStatementList(cnt: Int) {
        if(cnt > tokenManager.size()){
            Debug.warn("parseStatementList() exceeded size of token list, failure imminent", caller: self)
            return
        }
        
        parseStatement()
        parseStatementList(cnt+1)
        
        
    }
    
    func parseStatement() {
        let token = tokenManager.peekNextToken()
        
        switch(token.type){
            case TokenType.PRINT:
                parsePrintStatement()
            case TokenType.TYPE:
                parseVarDecl()
            case TokenType.WHILE:
                parseWhileStatement()
            case TokenType.IF:
                parseIfStatement()
            default:
                return
        }
    }
    
    func parsePrintStatement() {
        
    }
    func parseAssignmentStatement() {
        
    }
    func parseVarDecl() {
        
    }
    func parseWhileStatement() {
        
    }
    func parseIfStatement() {
        //consume "IF"
        tokenManager.consumeNextToken()
        parseBoolExpr()
        //parseBlock()
    }
    func parseBoolExpr() {
        var token = tokenManager.peekNextToken()
        print(token.value)
        if token.isType(TokenType.LPAREN) {
            tokenManager.consumeNextToken()
        }else{
            Debug.error("Invalid bool expr, no opening paren", caller: self)
        }
        
        parseExpr()
        
        parseBoolOp()
        
        parseExpr()
        
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.RPAREN) {
            tokenManager.consumeNextToken()
        }else{
            Debug.error("Invalid bool expr, no closing paren", caller: self)
            
        }
    }
    func parseExpr() {
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.DIGIT) {
            parseDigit()
        }
//        else if token.isType(TokenType.QUOTE) {
//            //string
//            
//        }else if token.isType(TokenType.CHAR) {
//            //id
//            
//        }else if token.isType(TokenType.LPAREN) {
//            //bool
//        
//        }
    }
    func parseBoolOp() {
        //let token = tokenManager.getNextToken()
        
    }
    func parseIntExpr() {
        
        //if this function was routed to, then we already know the next token is a digit
        parseDigit()
        
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.OPERATOR) {
            parsePlus()
            
            parseExpr()
        }
    }
    
    func parsePlus() {
        let token = tokenManager.consumeNextToken()
        if !token.isType(TokenType.PLUS){
            Debug.error("Invalid intop", caller: self)
        }
    }
    
    func parseDigit() {
        let token = tokenManager.consumeNextToken()
        if !token.isType(TokenType.DIGIT){
            Debug.error("Invalid digit", caller: self)
        }
    }
    
    
}