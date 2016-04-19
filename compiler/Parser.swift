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
    var progCount = 1;
    let debug = Debug.sharedInstance

    var tokenManager: TokenManager
    var CST: SyntaxTreeNode
    
    
    init() {
        // TODO: stop using this dummy initialization to suppress error
        self.tokenManager = TokenManager(tokens: [])
        self.CST = SyntaxTreeNode(value: "Program", isLeaf: false)
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
    
    func parse(tokens: [Token]) -> Bool {
        debug.log("Parsing...", caller: self)
        self.tokenManager = TokenManager(tokens: tokens)

        let parserStart = NSDate().timeIntervalSince1970 //mark time when parser starts
        
        debug.log("parse()", caller: self)
        let parseSucceeded = parseProgram()

        let parserStop = NSDate().timeIntervalSince1970 //mark time when parser compleres
        let executionTime = Int(Double(round(1000*(parserStop - parserStart))/1000)*1000)
        
        if parseSucceeded{
            debug.affirm("Parse succeeded, "+String(executionTime)+"ms", caller: self)
            return true
        }
        else{
            debug.error("Parse failed, "+String(executionTime)+"ms", caller: self)
            return false
        }
    }
    
    func parseProgram() -> Bool {
        debug.log("parseProgram()", caller: self)
        //self.CST = SyntaxTreeManager()
        self.CST = SyntaxTreeNode(value: "Program", isLeaf: false)

        if !parseBlock(){
            return false
        }
        
        if !matchAndConsume(TokenType.EOL, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST.addLeaf("$")

        return true
    }
    
    func parseBlock() -> Bool {
        debug.log("parseBlock()", caller: self)
       self.CST = self.CST.addNode("BLOCK")
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.LBRACE, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseStatementList(){
            return false
        }
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.RBRACE, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }
    
    func parseStatementList() -> Bool {
        debug.log("parseStatementList()", caller: self)
        self.CST = self.CST.addNode("Statement List")

        //peeking ahead to see if this is a ε case
        if tokenManager.hasNextToken() {
            if (tokenManager.peekNextToken()?.type == TokenType.RBRACE) {
                //RBRACE will be consumed by parseBlock
                self.CST = self.CST.parent!
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
        
        self.CST = self.CST.parent!
        return true
    }
    
    func parseStatement() -> Bool {
        debug.log("parseStatement()", caller: self)
        self.CST = self.CST.addNode("Statement")
        
        let token = tokenManager.peekNextToken()
        //TODO: move parent and return outside of switch
        switch(token!.type){
            case TokenType.PRINT:
                let result = parsePrintStatement()
                self.CST = self.CST.parent!
                return result
            case TokenType.TYPE:
                let result = parseVarDecl()
                self.CST = self.CST.parent!
                return result
            case TokenType.WHILE:
                let result = parseWhileStatement()
                self.CST = self.CST.parent!
                return result
            case TokenType.CHAR:
                let result = parseAssignmentStatement()
                self.CST = self.CST.parent!
                return result
            case TokenType.IF:
                let result = parseIfStatement()
                self.CST = self.CST.parent!
                return result
            case TokenType.LBRACE:
                let result = parseBlock()
                self.CST = self.CST.parent!
                return result
            default:
                self.CST = self.CST.parent!
                return false
        }
    }
    
    func parsePrintStatement() -> Bool {
        debug.log("parsePrintStatement()", caller: self)
       self.CST = self.CST.addNode("Print Statement")
        
        //check for PRINT
        CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.PRINT, token: tokenManager.peekNextToken()){
            return false
        }
        
        //check for (
        CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        //check for Expr
        if !(parseExpr()){
            return false
        }
        
        //check for )
        CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
        
    }
    func parseAssignmentStatement() -> Bool {
        debug.log("parseAssignmentStatement()", caller: self)
        self.CST = self.CST.addNode("Assignment Statement")
        
        //id
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.ASSIGN, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseExpr(){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }
    
    func parseVarDecl() -> Bool {
        debug.log("parseVarDecl()", caller: self)
        self.CST = self.CST.addNode("Variable Declaration")
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.TYPE, token: tokenManager.peekNextToken()){
            return false
        }
        
        //id
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }

    func parseWhileStatement() -> Bool {
        debug.log("parseWhileStatement()", caller: self)
        self.CST = self.CST.addNode("While Statement")
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.WHILE, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseBoolExpr(){
            return false
        }
        
        if !parseBlock(){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }
    
    func parseIfStatement() -> Bool {
        debug.log("parseIfStatement()", caller: self)
        self.CST = self.CST.addNode("If Statement")
        
        //consume "IF"
        tokenManager.consumeNextToken()
        if !parseBoolExpr(){
            return false
        }
        
        if !parseBlock(){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }
    
    func parseBoolExpr() -> Bool {
        debug.log("parseBoolExpr()", caller: self)
        self.CST = self.CST.addNode("Boolean Expression")
        
        //consume "("
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.LPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        //check for boolval first
        if tokenManager.peekNextToken()?.type == TokenType.BOOLVAL{
            self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
            if matchAndConsume(TokenType.BOOLVAL, token: tokenManager.peekNextToken()){
                //consume ")"
                self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
                if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
                    return false
                }
                self.CST = self.CST.parent!
                return true
            }
        }
        
        //if not boolval, contunue evaluating for boolean expr
        if !parseExpr() {
            return false
        }
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.BOOLOP, token: tokenManager.peekNextToken()){
            return false
        }
        
        if !parseExpr() {
            return false
        }
        
        self.CST.addLeaf((tokenManager.peekNextToken()?.value)!)
        if !matchAndConsume(TokenType.RPAREN, token: tokenManager.peekNextToken()){
            return false
        }
        
        self.CST = self.CST.parent!
        return true
    }
    func parseExpr() -> Bool {
        debug.log("parseExpr()", caller: self)
       self.CST = self.CST.addNode("Expression")
        
        let token = tokenManager.peekNextToken()
        
        if token!.isType(TokenType.DIGIT) {
            let result = parseIntExpr()
            self.CST = self.CST.parent!
            return result
        }
        else if token!.isType(TokenType.STRING) {
            self.CST = self.CST.addNode("String Expression")
            if !parseCharList() {
                return false
            }
            self.CST = self.CST.parent!
            return true
        }
        else if token!.isType(TokenType.CHAR) {
            let charVal = tokenManager.peekNextToken()?.value
            if !matchAndConsume(TokenType.CHAR, token: tokenManager.peekNextToken()){
                return false
            }
            self.CST.addLeaf(charVal!)
            self.CST = self.CST.parent!
            return true
        }
        else if token!.isType(TokenType.LPAREN) || token!.isType(TokenType.BOOLVAL) {
            let result = parseBoolExpr()
            self.CST = self.CST.parent!
            return result
        }
        else{
            print("Invalid Expression")
            return false
        }
    }
    
    func parseCharList() -> Bool {
        //hacking this for now
        debug.log("parseCharList()", caller: self)
        self.CST.addLeaf("\"")
        self.CST = self.CST.addNode("Char List")
        
        var string = tokenManager.peekNextToken()?.value
        //remove quotes ( " ) from strnig
        string = String(string!.characters.dropLast())
        string = String(string!.characters.dropFirst())
        
        if !matchAndConsume(TokenType.STRING, token: tokenManager.peekNextToken()){
            return false
        }
        
        //handle empty string
        if string! == "" {
            self.CST.addLeaf("")
            self.CST.addLeaf("Char List")
            self.CST = self.CST.parent!
        } else {
            if !parseCharListAid(string!) {
                return false
            }
        }
     
        self.CST.addLeaf("\"")
        self.CST = self.CST.parent!
        return true

    }
    func parseCharListAid(string: String) -> Bool {
        let char = String(string[string.startIndex])
        
//        if string.characters.count == 1 {
//            self.CST = self.CST.parent!
//            return true
//        }
        
        self.CST.addLeaf(char)
        self.CST = self.CST.addNode("Char List")
        
        if string.characters.count > 1 {
            parseCharListAid(String(string.characters.dropFirst()))
        }else{
            self.CST = self.CST.parent!
        }
        //parseCharListAid(String(string.characters.dropFirst()))

        
        self.CST = self.CST.parent!
        return true
    }

    func parseIntExpr() -> Bool {
        debug.log("parseIntExpr()", caller: self)
       self.CST = self.CST.addNode("Int Expression")
        
        if tokenManager.peekNextToken()?.type == TokenType.DIGIT {
            CST.addLeaf((tokenManager.peekNextToken()?.value)!)
            if !matchAndConsume(TokenType.DIGIT, token: tokenManager.peekNextToken()){
                return false
            }
        }
        
        if tokenManager.peekNextToken()!.isType(TokenType.INTOP) {
            CST.addLeaf((tokenManager.peekNextToken()?.value)!)
            if !matchAndConsume(TokenType.INTOP, token: tokenManager.peekNextToken()){
                return false
            }
            
            if !parseExpr(){
                return false
            }
           
        }
        self.CST = self.CST.parent!

        return true
    }
}