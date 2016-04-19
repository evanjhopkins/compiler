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
        self.AST = SyntaxTreeNode(value: "< Program >", isLeaf: false)
        self.scope = Scope()
        self.varUsage = [:]
    }
    
    func analyze(CST: SyntaxTreeNode) -> Bool {
        debug.affirm("Analyzing...", caller: self)
        //TODO: handle failure detections on these steps
        debug.log("Building AST", caller: self)
        self.AST = buildASTr(CST)!
        condenseStatementLists()
        
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
                debug.error("Variable '" + k + "' declared but never assigned", caller: self)
            }else if (v == "assigned") {
                debug.error("Variable '" + k + "' assigned but never used", caller: self)
            }
        }
    }
    
    func buildAST(CST: SyntaxTreeNode) -> SyntaxTreeNode? {
        self.AST = buildASTr(CST)!
        condenseStatementLists()
        buildSymbolTable(self.AST)
        self.scope.display()
        return self.AST
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
            if self.scope.immediateScopeCheck(node.children[1].value) {
                debug.error("Variable '" + node.children[1].value + "' was already declared", caller: self)
                return false
            }
            //set this variable to the declared stage
            self.varUsage[node.children[1].value] = "declared"
            let type = node.children[0].value
            let name = node.children[1].value
            //add it to current scope
            self.scope.addSymbol(name, type: type, line: 0)
        } else if (node.value == "Assignment Statement") {
            //is the variable in scope?
            if !self.scope.scopeCheck(node.children[0].value) {
                debug.error("Variable '" + node.children[0].value + "' was used before being declared" , caller: self)
                return false
            }

            //is the value of the correct type?
            if !self.typeCheck(node) {
                return false
            }
            
            //set the variable to the assigned stage
            self.varUsage[node.children[0].value] = "assigned"

        } else if(node.value == "Print Statement") {
            //is this a raw value or var?
            if (node.children[0].value.rangeOfString("[a-z]", options: .RegularExpressionSearch) == node.children[0].value.characters.indices) {
                //is variable in scope?
                if !self.scope.scopeCheck(node.children[0].value) {
                    debug.error("Variable '" + node.children[0].value + "' was used before being declared" , caller: self)
                }
                //set the variable to the used (final) stage
                self.varUsage[node.children[0].value] = "used"
            }else {
                //raw value
            }
        } else if(node.value == "Boolean Expression") {
            if node.children[1].value == "==" {
                if !exprTypeCheck(node){
                    return false
                }
            }
            //let left = node.children[0]
            
        } else{
            //if not a special case, do nothing and iterate over children
            for child in node.children {
                if !buildSymbolTable(child) {
                    return false
                }
            }
        }
        return true
    }

    func exprTypeCheck(node: SyntaxTreeNode) -> Bool {
        let leftType = valType(node.children[0].value)
        let rightType = valType(node.children[2].value)

        if leftType == rightType{
            return true
        }
        debug.error("Type mismatch, '" + node.children[0].value + "' not type compatable with '" + node.children[2].value+"'", caller: self)
        return false
    }
    
    //confirm the action being conducted by node obeys type restrictions
    func typeCheck(node: SyntaxTreeNode) -> Bool {
        let symbol = self.scope.getSymbol(node.children[0].value)
        let idTypex = idType((symbol?.type)!)
        let valueTypex = valType(node.children[1].value)
        
        if (idTypex != valueTypex) {
            debug.error("Type mismatch, '" + node.children[1].value + "' is not of type " + idTypex!.rawValue, caller: self)
            return false
        }
        return true
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
    func valType(value: String) -> TokenType? {
        let patterns:[(type: TokenType, pattern: String)] = [
            (TokenType.DIGIT, "[0-9]"),
            (TokenType.BOOLVAL, "true|false"),
            (TokenType.STRING, "[a-zA-Z0-9 ]*")
        ]
        
        for pattern in patterns {
            if value.rangeOfString(pattern.pattern, options: .RegularExpressionSearch) == value.characters.indices {
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
        let astNode = SyntaxTreeNode(value: CST.value, isLeaf: CST.isLeaf)
        
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
                astNode.addLeaf(val)
            }
        }
        
        return astNode
    }
    
    //recusive func to rebuild string from char list chains
    private func buildString(charList: SyntaxTreeNode) -> String {
        if charList.children.count == 2 {
            return charList.children[0].value + buildString(charList.children[1])
        }
        return ""
    }
}