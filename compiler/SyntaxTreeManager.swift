//
//  SyntaxTreeManager.swift
//  compiler
//
//  Created by Evan Hopkins on 4/14/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

class SyntaxTreeManager: CompilerComponentProtocol  {
    var CLASSNAME: String = "SEMANTIC"
    let debug = Debug.sharedInstance
    var AST: SyntaxTreeNode
    var scope: Scope
    var varUsage: [String:String]
    
    
    init() {
        //allow init to be empty, detect no value rather than add child
        self.AST = SyntaxTreeNode()
        self.scope = Scope()
        self.varUsage = [:]
    }
    
    func analyze(AST: SyntaxTreeNode) -> Bool {
        debug.affirm("Analyzing...", caller: self)
        //TODO: handle failure detections on these steps

        
        //debug.log("Building AST", caller: self)
        //self.AST = buildASTr(CST)!
        //condenseStatementLists()
        
        self.AST = AST
        debug.log("Building symbol table", caller: self)
        
        if !buildSymbolTable(self.AST) {
            debug.error("Analysis failed", caller: self)
            return false
        }
        
        debug.log("Checking variable usage", caller: self)
        checkVariableUsage()
        
        debug.affirm("Analysis succeeded", caller: self)
        return true
    }
    
    func checkVariableUsage() {
        for (k,v) in self.varUsage {
            if v == "declared" {
                debug.error("(warn) Variable '" + k + "' declared but never assigned", caller: self)
            }else if (v == "assigned") {
                debug.error("(warn) Variable '" + k + "' assigned but never used", caller: self)
            }
        }
    }
    
    //build a tree of symbol tables representing the scopes of variables
    func buildSymbolTable(node: SyntaxTreeNode) -> Bool {
        if node.value == "BLOCK" {
            //when a new block is created, we must create a child scope
            self.scope = self.scope.subScope()
            for child in node.children {
                if !buildSymbolTable(child) {
                    return false
                }
            }
            self.scope = self.scope.parent!
        } else if (node.value == "Variable Declaration"){
            //make sure this is not a redeclaration
            if self.scope.immediateScopeCheck(node.children[1].value!) {
                debug.error("Variable '" + node.children[1].value! + "' was already declared", caller: self)
                return false
            }
            //set this variable to the declared stage
            self.varUsage[node.children[1].value!] = "declared"
            let type = node.children[0].value
            let name = node.children[1].value
            //add it to current scope
            self.scope.addSymbol(name!, type: type!, line: 0)
        } else if (node.value == "Assignment Statement") {
            
            //is the variable in scope?
            if !self.scope.scopeCheck(node.children[0].value!) {
                debug.error("Variable '" + node.children[0].value! + "' was used before being declared" , caller: self)
                //user never declared var, lets do it for them
                self.varUsage[node.children[1].value!] = "declared"
                let name = node.children[0].value
                let type: TokenType = valType(node.children[1])!
                self.scope.addSymbol(name!, type: tokenTypeToScopeType(type), line: 0)
                return false
            }

            //is the value of the correct type?
            if !self.typeCheck(node) {
                return false
            }
            
            //set the variable to the assigned stage
            self.varUsage[node.children[0].value!] = "assigned"

        } else if(node.value == "Print Statement") {
            //is this a raw value or var?
            if (node.children[0].value!.rangeOfString("[a-z]", options: .RegularExpressionSearch) == node.children[0].value!.characters.indices) {
                //is variable in scope?
                if !self.scope.scopeCheck(node.children[0].value!) {
                    debug.error("(warn) Variable '" + node.children[0].value! + "' was used before being declared" , caller: self)
                }
                //set the variable to the used (final) stage
                self.varUsage[node.children[0].value!] = "used"
            }else {
                //raw value
            }
        } else if(node.value == "Boolean Expression") {
            if node.children[1].value == "==" {
                if !typeCheck(node){
                    return false
                }
            }
            //let left = node.children[0]
            
        } else if(node.value == "==" || node.value == "+") {
            if !typeCheck(node) {
                return false
            }
        }else{
            //if not a special case, do nothing and iterate over children
            for child in node.children {
                if !buildSymbolTable(child) {
                    return false
                }
            }
        }
        return true
    }
    
    func tokenTypeToScopeType(type: TokenType) -> String {
        if type == TokenType.STRING {
            return "String"
        } else if type == TokenType.BOOLVAL {
            return "Boolean"
        } else if type == TokenType.DIGIT {
            return "Int"
        } else {
            return "ERROR"
        }
    }
    
    //confirm the action being conducted by node obeys type restrictions
    func typeCheck(node: SyntaxTreeNode) -> Bool {
        //node should be ==, +, assignment statement
        let left = node.children[0]
        let right = node.children[1]
        
        if left.value=="+" {
            return typeCheck(left)
        }
        if right.value=="+" {
            return typeCheck(right)
        }
        
        if node.value == "Assignment Statement" {
            let typeInScope = idType(self.scope.getSymbol(left.value!)!.type)
            let typeOfAsignee = valType(right)
            if (typeInScope == typeOfAsignee) {
                return true
            }
            
        } else if (node.value == "==" || node.value == "+") {
            if (valType(left) == valType(right)) {
                return true
            }
        }
        debug.error("Type-check failed, cannot compare '"+left.value!+"'("+String(valType(left))+") to '"+right.value!+"'", caller: self)
        return false
    }
    
    //extract type from AST node names
    //TODO: this is a workaround for now, eventually the tree nodes will store type
    func idType(value: String) -> TokenType? {
        switch value {
        case "boolean":
            return TokenType.BOOLVAL
        case "int":
            return TokenType.DIGIT
        case "string":
            return TokenType.STRING
        default:
            return nil
        }
    }
    
    //re-lex type of leaf
    //TODO: this is a workaround for now, eventually the tree nodes will store type
    
    func valType(node: SyntaxTreeNode) -> TokenType? {
        let value = node.value!
        
        
        let patterns:[(type: TokenType, pattern: String)] = [
            (TokenType.DIGIT, "[0-9]"),
            (TokenType.BOOLVAL, "true|false"),
            (TokenType.CHAR, "[a-z]"),
            (TokenType.STRING, "\"[a-zA-Z0-9 ]*\"")
        ]
        
        for pattern in patterns {
            if value.rangeOfString(pattern.pattern, options: .RegularExpressionSearch) == value.characters.indices {
                if pattern.type == TokenType.CHAR {
                    return idType(self.scope.getSymbol(value)!.type)
                }
                return pattern.type
            }
        }
        return nil
    }
    
    //part of building ast, just moved this portion to its own func
    //handles bubling statement lists up to the top of the chain
    private func condenseStatementLists() {

        for child in AST.children {
            self.AST = child
            condenseStatementLists()
        }
        
        if self.AST.value == "Statement List" {
            for child in AST.children {
                self.AST.parent?.addChild(child)
            }
            for (index, v) in AST.parent!.children.enumerate() {
                if v.value == "Statement List"{
                    AST.parent!.children.removeAtIndex(index)
                }
            }
        }
        
        if((self.AST.parent) != nil) {
            self.AST = self.AST.parent!
        }
    }
    
    //recursive part of buidling ast
    func buildASTr(CST: SyntaxTreeNode) -> SyntaxTreeNode? {
        var astNode = SyntaxTreeNode(value: CST.value!)
        
        if CST.children.count == 1 {
            return buildASTr(CST.children.first!)
        }else {
            for child in CST.children {
                let childAST = buildASTr(child)
                if childAST != nil{
                    astNode.addChild(childAST!)
                }
            }
        }
        
        if CST.isLeaf {
            if ((CST.value == "}") ||
               (CST.value == "{") ||
               (CST.value == "(") ||
               (CST.value == ")") ||
               (CST.value == "=")) {
                return nil
            }
        } else {
            if CST.value == "Program" {
                return buildASTr(CST.children[0])
            }
            
            if CST.value == "Statement List"{
                if CST.children.count > 0 {
//                    let node = astNode.children.first
//                    node?.addNode(astNode.children[1].value)
//                    return node
                } else {
                    return nil
                }
            }
            
            if CST.value == "String Expression" {
                astNode.value = buildString(CST.children[1])
                astNode.isLeaf = true
                astNode.children = []
            }
            
            if CST.value == "Print Statement" {
                let val = astNode.children[1].value
                astNode.children = []
                astNode.addLeaf(val!)
            }
            
            if CST.value == "Int Expression" {
                if (CST.children.count > 2) {
                    astNode = handleIntExpr(CST)
                }
            }
        }
        
        return astNode
    }
    
    private func handleIntExpr(CST: SyntaxTreeNode) -> SyntaxTreeNode {
        if CST.children.count == 1 {
            return handleIntExpr(CST.children[0])
        }
        if CST.children.count == 0 {
            return CST
        }
        
        let astNode = SyntaxTreeNode(value: CST.children[1].value!)
        
        if (valType(CST.children[0]) == TokenType.DIGIT){
            astNode.addLeaf(CST.children[0].value!)
        }else{
            astNode.children.append(handleIntExpr(CST.children[0]))
        }
        if (valType(CST.children[2]) == TokenType.DIGIT){
            astNode.addLeaf(CST.children[2].value!)
        }else{
            astNode.children.append(handleIntExpr(CST.children[2]))
        }
        
        return astNode
    }
    
    //recusive func to rebuild string from char list chains
    private func buildString(charList: SyntaxTreeNode) -> String {
        if charList.children.count == 2 {
            return charList.children[0].value! + buildString(charList.children[1])
        }
        return ""
    }
}