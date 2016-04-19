//
//  SyntaxTreeNode.swift
//  compiler
//
//  Created by Evan Hopkins on 4/14/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

//a tree structure to store AST/CST trees
class SyntaxTreeNode {
    var parent: SyntaxTreeNode?
    //let token: Token
    var value: String
    var children: [SyntaxTreeNode]
    var isLeaf: Bool
    //var type: TokenType?
    
    //init node with parent
    init(value: String, parent: SyntaxTreeNode?, isLeaf: Bool) {
        self.value = value
        self.children = []
        self.isLeaf = isLeaf
    }
    
    //init node without parent
    convenience init(value: String,isLeaf: Bool) {
        self.init(value: value, parent: nil, isLeaf: isLeaf)
    }

    func setParent(parent: SyntaxTreeNode) {
        self.parent = parent
        self.parent?.addChild(self)
    }
    
    func addChild(child: SyntaxTreeNode) {
        child.parent = self
        self.children.append(child)
    }
    
    //add a child and decend into that child
    func addNode(value: String) -> SyntaxTreeNode {
        let newNode = SyntaxTreeNode(value: value, isLeaf: false)
        newNode.setParent(self)
        return newNode
    }
    
    //add a child, but do not decend into that child for it is an only child with no children
    func addLeaf(value: String) {
        let newNode = SyntaxTreeNode(value: value, isLeaf: true)
        //newNode.type = type
        newNode.setParent(self)
    }
    
    func display() {
        self.display(0)
    }
    
    private func display(depth: Int) {
        let spacer: String = String(count: depth, repeatedValue: Character("-"))
        
        var wrappedValue: String
        if self.isLeaf {
            wrappedValue = "[ "+self.value+" ]"
        }else {
            wrappedValue = "< "+self.value+" >"
        }
        print(spacer + wrappedValue)
        for child in self.children {
            child.display(depth+1)
        }
    }
}
