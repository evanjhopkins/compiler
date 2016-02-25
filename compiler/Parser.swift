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
    
    init(tokenss: [Token]) {
        self.tokenManager = TokenManager(tokens: tokenss)
    }
    
    func parse() {
        parseBlock()
        debug.affirm("Parse completed successfully", caller: self)
    }
    
    func parseBlock() {
        if !tokenManager.hasNextToken() {
            return
        }
        
        var token = tokenManager.peekNextToken()
        if token.isType(TokenType.LBRACE) {
            //consume "{"
            tokenManager.consumeNextToken()
        }else{
            debug.error("Invalid block, no opening brace", caller: self)
        }
        
        parseStatementList()
        
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.RBRACE) {
            //consume "{"
            tokenManager.consumeNextToken()
        }else{
            debug.error("Invalid block, no closing brace", caller: self)
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
        var token = tokenManager.peekNextToken()
        if token.isType(TokenType.PRINT) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(TokenType.PRINT, got: token)
        }
        
        //check for (
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.LPAREN) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(TokenType.LPAREN, got: token)
        }
        
        //check for Expr
        parseExpr()
        
        //check for )
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.RPAREN) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(TokenType.RPAREN, got: token)
        }
        
    }
    func parseAssignmentStatement() {
        parseId()
        
        parseAssign()
        
        parseExpr()
    }
    func parseVarDecl() {
        
    }
    func parseWhileStatement() {
        
    }
    func parseIfStatement() {
        //consume "IF"
        tokenManager.consumeNextToken()
        parseBoolExpr()
        parseBlock()
    }
    func parseBoolExpr() {
        var token = tokenManager.peekNextToken()
        if token.isType(TokenType.LPAREN) {
            tokenManager.consumeNextToken()
        }else{
            parseError("Invalid bool expr, no opening paren")
        }
        
        parseExpr()
        
        parseBoolOp()
        
        parseExpr()
        
        token = tokenManager.peekNextToken()
        if token.isType(TokenType.RPAREN) {
            tokenManager.consumeNextToken()
        }else{
            parseError("Invalid bool expr, no closing paren")
        }
    }
    func parseExpr() {
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.DIGIT) {
            parseIntExpr()
        }
        else if token.isType(TokenType.STRING) {
            parseString()
        }
        else if token.isType(TokenType.CHAR) {
            parseId()
        }
        else if token.isType(TokenType.LPAREN) {
            parseBoolExpr()
        }
        else{
            parseError("Invalid Expression")
            //exit(0)
        }
    }
    func parseBoolOp() {
        let token = tokenManager.peekNextToken()
        if token.isType(TokenType.BOOLOP){
            tokenManager.consumeNextToken()
        }else{
            parseError("Invalid BoolOp")
        }
    }
    func parseIntExpr() {
        
        //if this function was routed to, then we already know the next token is a digit
        parseDigit()
        
        let token = tokenManager.peekNextToken()
        
        if token.isType(TokenType.INTOP) {
            parseIntOp()
            
            parseExpr()
        }
    }
    
    func parseIntOp() {
        let expectedType = TokenType.INTOP
        let token = tokenManager.peekNextToken()
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(expectedType, got: token)
        }
    }
    func parseDigit() {
        let expectedType = TokenType.DIGIT
        let token = tokenManager.peekNextToken()
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(expectedType, got: token)
        }
    }
    func parseString() {
        let expectedType = TokenType.STRING
        let token = tokenManager.peekNextToken()
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(expectedType, got: token)
        }
    }
    func parseId() {
        let expectedType = TokenType.CHAR
        let token = tokenManager.peekNextToken()
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(expectedType, got: token)
        }
    }
    func parseAssign() {
        let expectedType = TokenType.ASSIGN
        let token = tokenManager.peekNextToken()
        if token.isType(expectedType) {
            tokenManager.consumeNextToken()
        }else{
            parseTokenError(expectedType, got: token)
        }
    }
    
    func parseTokenError(expected: TokenType, got: Token) {
        debug.error("Expected ["+String(expected)+"] got ["+String(got.type)+"] with value '"+got.value+"' on line "+String(got.line), caller: self)
        failParse()
    }
    func parseError(message: String) {
        debug.error(message, caller: self)
        failParse()
    }
    func failParse() {
        debug.error("Parser terminating...", caller: self)
        //exit(0)
    }
    
    
}