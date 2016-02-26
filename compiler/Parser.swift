//
//  Parser.swift
//  compiler
//
//  Created by Evan Hopkins on 2/24/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation
//import Darwin

class Parser: CompilerComponentProtocol {
    var CLASSNAME = "PARSER"
    var VERBOSE = true
    let debug = Debug.sharedInstance

    let tokenManager: TokenManager
    
    init(tokens: [Token]) {
        self.tokenManager = TokenManager(tokens: tokens)
    }
    
    
    //given a token and an expected token type, return true if token is the expected type
    func matchAndConsume(expectedType: TokenType, token: Token) -> Bool {
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
            return true
        }else{
            debug.error("Expected ["+String(expectedType)+"] got ["+String(token.type)+"] with value '"+token.value+"' on line "+String(token.line), caller: self)
            return false
        }
    }
    
    func parse() {
        parseBlock()
        
        
        debug.affirm("Parse completed successfully", caller: self)
    }
    
    func parseBlock() {
//        if !tokenManager.hasNextToken() {
//            return
//        }
        
        if !matchAndConsume(TokenType.LBRACE, token: tokenManager.peekNextToken()){
            return
        }
        
        parseStatementList()
        
        if !matchAndConsume(TokenType.RBRACE, token: tokenManager.peekNextToken()){
            return
        }
        
    }
    
    func parseStatementList() {
        parseStatementList(0)
    }
    func parseStatementList(cnt: Int) {
        if tokenManager.hasNextToken() {
            parseStatement()
            parseStatementList(cnt+1)
        }
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
            case TokenType.LBRACE:
                parseBlock()
            default:
                return
        }
    }
    
    func parsePrintStatement() {
        //check for PRINT
        if !matchAndConsume(TokenType.PRINT, token: tokenManager.peekNextToken()){
            return
        }
        
        //check for (
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return
        }
        
        //check for Expr
        parseExpr()
        
        //check for )
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return
        }
        
    }
    func parseAssignmentStatement() {
        //id
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return
        }
        
        if !matchAndConsume(TokenType.ASSIGN, token: tokenManager.peekNextToken()){
            return
        }
        
        parseExpr()
    }
    func parseVarDecl() {
        if !matchAndConsume(TokenType.TYPE, token: tokenManager.peekNextToken()){
            return
        }
        
        //id
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return
        }
    }

    func parseWhileStatement() {
        if !matchAndConsume(TokenType.WHILE, token: tokenManager.peekNextToken()){
            return
        }
        
        parseBoolExpr()
        
        parseBlock()
        
    }
    func parseIfStatement() {
        //consume "IF"
        tokenManager.consumeNextToken()
        parseBoolExpr()
        parseBlock()
    }
    func parseBoolExpr() {
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return
        }
        
        parseExpr()
        
        if !matchAndConsume(TokenType.BOOLOP, token: tokenManager.peekNextToken()){
            return
        }
        
        parseExpr()
        
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return
        }
    }
    func parseExpr() {
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.DIGIT) {
            parseIntExpr()
        }
        else if token.isType(TokenType.STRING) {
            if !matchAndConsume(TokenType.STRING, token: tokenManager.peekNextToken()){
                return
            }
        }
        else if token.isType(TokenType.CHAR) {
            if !matchAndConsume(TokenType.LBRACE, token: tokenManager.peekNextToken()){
                return
            }
        }
        else if token.isType(TokenType.LPAREN) {
            parseBoolExpr()
        }
        else{
            print("Invalid Expression")
            return
        }
    }

    func parseIntExpr() {
        
        if !matchAndConsume(TokenType.DIGIT, token: tokenManager.peekNextToken()){
            return
        }
        
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.INTOP) {
            if !matchAndConsume(TokenType.INTOP, token: tokenManager.peekNextToken()){
                return
            }
            
            parseExpr()
        }
    }
}