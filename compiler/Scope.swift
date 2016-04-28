//
//  Scope.swift
//  compiler
//
//  Created by Evan Hopkins on 4/18/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

//representation of a variable symbol and its associated attributes
class SymbolItem {
    let type: String
    let line: Int
    
    init(type: String, line: Int) {
        self.type = type
        self.line = line
    }
}

//a tree structure to store a symbol table (and is child tables(
class Scope {
    var symbolTable: [String:SymbolItem]
    var children: [Scope]
    var parent: Scope?
    
    init() {
        self.symbolTable = [:]
        self.children = []
    }
    
    func addChild(child: Scope) {
        child.parent = self
        self.children.append(child)
    }
    
    func addSymbol(name: String, type: String, line: Int) {
        let newSymbolItem = SymbolItem(type: type, line: line)
        //check if key exists, throw error
        self.symbolTable[name] = newSymbolItem
    }
    
    //create a sub (child) scope within the current scope
    func subScope() -> Scope {
        let subScope = Scope()
        subScope.parent = self
        subScope.parent!.children.append(subScope)
        return subScope
    }
    
    //find symbol given its id
    func getSymbol(id: String) -> SymbolItem? {
        if (symbolTable[id] != nil) {
            return symbolTable[id]
        }else{
            if (self.parent != nil) {
                return self.parent!.getSymbol(id)
            }
        }
        //print("Variable [" + id + "] was not found")
        return nil
    }
    
    //is a given id in the current scope or any above (parents)
    func scopeCheck(value: String) -> Bool {
        if (symbolTable[value] != nil) {
            return true
        }else{
            if (self.parent != nil) {
                return self.parent!.scopeCheck(value)
            }
        }
        //print("Variable [" + value + "] not in scope")
        return false
    }
    
    //is a given id in this immediate scope (i.e. not parents or childrens)
    func immediateScopeCheck(value: String) -> Bool {
        if (symbolTable[value] != nil) {
            return true
        }else{
            return false
        }
    }
    
    func display() {
        let name = stringFill("Name", size: 5)
        let type = stringFill("Type", size: 8)
        let line = stringFill("Line", size: 4)
        let depth = stringFill("Depth", size: 5)
        print("\nSymbol Table")
        print(name + " " + type + " " + line + " " + depth)
        print("-------------------------")

        self.display(0)
    }
    
    func display(depth: Int) {
        for (k,v) in self.symbolTable {
            let name = stringFill(k, size: 5)
            let type = stringFill(v.type, size: 8)
            let line = stringFill(String(v.line), size: 4)
            let depth = stringFill(String(depth-1), size: 5)
            print(name + " " + type + " " + line + " " + depth)
        }
        for child in self.children {
            child.display(depth+1)
        }
    }
    
    //pad strings for neat printing
    private func stringFill(value:String, size:Int) -> String {
        if value.characters.count <= size {
            let padding = size - value.characters.count
            return value + String(count: padding, repeatedValue: Character(" "))
        }else{
            return String(count: size, repeatedValue: Character("X"))

        }
    }
}

