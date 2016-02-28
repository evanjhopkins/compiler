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
    func matchAndConsume(expectedType: TokenType, token: Token?) -> Bool {
        if token == nil{
            debug.error("Expected ["+String(expectedType)+"] but no tokens remain", caller: self)
            return false
        }
        if token!.isType(expectedType) {
            tokenManager.consumeNextToken()
            return true
        }else{
            debug.error("Expected ["+String(expectedType)+"] got ["+String(token!.type)+"] with value '"+token!.value+"' on line "+String(token!.line), caller: self)
            return false
        }
    }
    
    func parse() {
        if parseProgram(){
            debug.affirm("Parse completed successfully", caller: self)
        }
        else{
            debug.error("Parse failed", caller: self)
        }
    }
    
    func parseProgram() -> Bool {
        if !parseBlock(){
            return false
        }
        
        if !matchAndConsume(TokenType.EOL, token: tokenManager.peekNextToken()){
            return false
        }
        return true
    }
    
    func parseBlock() -> Bool {
        
        if !matchAndConsume(TokenType.LBRACE, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseStatementList(){
            return false
        }
        
        if !matchAndConsume(TokenType.RBRACE, token: tokenManager.peekNextToken()){
            return false
        }
        return true
    }
    
    func parseStatementList() -> Bool {
        if !parseStatement(){
            return false
        }
        
        if tokenManager.hasNextToken() {
            if !parseStatementList(){
                return false
            }
        }
        return true
    }
    
    func parseStatement() -> Bool {
        let token = tokenManager.peekNextToken()
        switch(token!.type){
            case TokenType.PRINT:
                return parsePrintStatement()
            case TokenType.TYPE:
                return parseVarDecl()
            case TokenType.WHILE:
                return parseWhileStatement()
            case TokenType.ASSIGN:
                return parseAssignmentStatement()
            case TokenType.IF:
                return parseIfStatement()
            case TokenType.LBRACE:
                return parseBlock()
            default:
                return false
        }
    }
    
    func parsePrintStatement() -> Bool {
        //check for PRINT
        if !matchAndConsume(TokenType.PRINT, token: tokenManager.peekNextToken()){
            return false
        }
        
        //check for (
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        //check for Expr
        if !(parseExpr()){
            return false
        }
        
        //check for )
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        return true
        
    }
    func parseAssignmentStatement() -> Bool {
        //id
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !matchAndConsume(TokenType.ASSIGN, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseExpr(){
            return false
        }
        return true
    }
    func parseVarDecl() -> Bool {
        if !matchAndConsume(TokenType.TYPE, token: tokenManager.peekNextToken()){
            return false
        }
        
        //id
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return false
        }
        return true
    }

    func parseWhileStatement() -> Bool {
        if !matchAndConsume(TokenType.WHILE, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseBoolExpr(){
            return false
        }
        
        if !parseBlock(){
            return false
        }
        return true
    }
    func parseIfStatement() -> Bool {
        //consume "IF"
        tokenManager.consumeNextToken()
        if !parseBoolExpr(){
            return false
        }
        
        if !parseBlock(){
            return false
        }
        return true
    }
    func parseBoolExpr() -> Bool {
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseExpr() {
            return false
        }
        
        if !matchAndConsume(TokenType.BOOLOP, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseExpr() {
            return false
        }
        
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        return true
    }
    func parseExpr() -> Bool {
        let token = tokenManager.peekNextToken()
        
        if token!.isType(TokenType.DIGIT) {
            return parseIntExpr()
        }
        else if token!.isType(TokenType.STRING) {
            if !matchAndConsume(TokenType.STRING, token: tokenManager.peekNextToken()){
                return false
            }
            return true
        }
        else if token!.isType(TokenType.CHAR) {
            if !matchAndConsume(TokenType.LBRACE, token: tokenManager.peekNextToken()){
                return false
            }
            return true
        }
        else if token!.isType(TokenType.LPAREN) {
            return parseBoolExpr()
        }
        else{
            print("Invalid Expression")
            return false
        }
    }

    func parseIntExpr() -> Bool {
        
        if !matchAndConsume(TokenType.DIGIT, token: tokenManager.peekNextToken()){
            return false
        }
        
        let token = tokenManager.peekNextToken()
        
        if token!.isType(TokenType.INTOP) {
            if !matchAndConsume(TokenType.INTOP, token: tokenManager.peekNextToken()){
                return false
            }
            
            if !parseExpr(){
                return false
            }
        }
        return true
    }
}