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
    var progCount = 1;
    let debug = Debug.sharedInstance

    var tokenManager: TokenManager
    
    init() {
        // TODO: stop using this dummy initialization to suppress error
        self.tokenManager = TokenManager(tokens: [])
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
    
    func parser(tokens: [Token]) -> Bool {
        self.tokenManager = TokenManager(tokens: tokens)
        debug.log("Parsing...", caller: self)
        let parserStart = NSDate().timeIntervalSince1970 //mark time when parser starts
        let parseSucceeded = parse()
        let parserEnd = NSDate().timeIntervalSince1970 //mark time when parser compleres
        let executionTime = parserEnd - parserStart
        
        if parseSucceeded {
            debug.affirm("Parse succeeded, "+String(executionTime)+"s", caller: self)
            return true
        }else {
            debug.error("Parse failed, "+String(executionTime)+"s", caller: self)
            return false
        }
    }
    
    func parse() -> Bool {
        debug.log("parse()", caller: self)
        if parseProgram(){
            //debug.affirm("Parse completed successfully in: "+String(executionTime)+"s", caller: self)
        }
        else{
            //consume remaining tokens in this broken program
            tokenManager.findEndOfCurrentProgram()
            return false
        }
        
        //handle possibility of multiple programs in one file
        if tokenManager.hasNextToken() {
            self.progCount += 1
            parse()
        }
        return true
    }
    
    func parseProgram() -> Bool {
        debug.log("parseProgram()", caller: self)

        if !parseBlock(){
            return false
        }
        
        if !matchAndConsume(TokenType.EOL, token: tokenManager.peekNextToken()){
            return false
        }
        return true
    }
    
    func parseBlock() -> Bool {
        debug.log("parseBlock()", caller: self)

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
        debug.log("parseStatementList()", caller: self)

        //peeking ahead to see if this is a ε case
        if tokenManager.hasNextToken() {
            if (tokenManager.peekNextToken()?.type == TokenType.RBRACE) {
                //RBRACE will be consumed by parseBlock
                return true
            }
        }
        
        //otherwise evalueate like normal
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
        debug.log("parseStatement()", caller: self)

        let token = tokenManager.peekNextToken()
        switch(token!.type){
            case TokenType.PRINT:
                return parsePrintStatement()
            case TokenType.TYPE:
                return parseVarDecl()
            case TokenType.WHILE:
                return parseWhileStatement()
            case TokenType.CHAR:
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
        debug.log("parsePrintStatement()", caller: self)

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
        debug.log("parseAssignmentStatement()", caller: self)

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
        debug.log("parseVarDecl()", caller: self)

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
        debug.log("parseWhileStatement()", caller: self)

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
        debug.log("parseIfStatement()", caller: self)

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
        debug.log("parseBoolExpr()", caller: self)

        //check for boolval first
        if tokenManager.peekNextToken()?.type == TokenType.BOOLVAL{
            if matchAndConsume(TokenType.BOOLVAL, token: tokenManager.peekNextToken()){
                return true
            }
        }
        
        //if not boolval, contunue evaluating for boolean expr
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
        debug.log("parseExpr()", caller: self)

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
            if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
                return false
            }
            return true
        }
        else if token!.isType(TokenType.LPAREN) || token!.isType(TokenType.BOOLVAL) {
            return parseBoolExpr()
        }
        else{
            print("Invalid Expression")
            return false
        }
    }

    func parseIntExpr() -> Bool {
        debug.log("parseIntExpr()", caller: self)

        if tokenManager.peekNextToken()?.type == TokenType.DIGIT {
            if !matchAndConsume(TokenType.DIGIT, token: tokenManager.peekNextToken()){
                return false
            }
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