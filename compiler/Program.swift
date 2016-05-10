//
//  Program.swift
//  compiler
//
//  Created by Evan Hopkins on 3/31/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Program: CompilerComponentProtocol {
    //eventuall split program and compiler into individual classes
    var CLASSNAME = "COMPILER"
    let debug = Debug.sharedInstance
    let source: String
    let programId: String//i.e. program number
    let lexer: Lexer
    let parser: Parser
    let analyzer: SyntaxTreeManager
    let code: Code
    
    init(source: String, programId: String) {
        self.source = source
        self.programId = programId
        self.lexer = Lexer()
        self.parser = Parser()
        self.analyzer = SyntaxTreeManager()
        self.code = Code()
    }
    
    func compile() {
        debug.affirm("Compiling program "+String(self.programId), caller: self)
        
        if lex() {
            if parse(self.lexer.getTokens()) {
                if analyze(parser.AST) {
                    debug.affirm("Compile succeeded", caller: self)
                    let out = code.generateCode(parser.AST)
                    
                    
                    if debug.verbose {
                        print("\nCST")
                        parser.CST.display()
                        print("\nAST")
                        parser.AST.display()
                        analyzer.scope.display()
                    }
                    print(out)
                    print("----------------------------------------------------------------------")
                    return
                }
            }
        }
        //parser.AST.display()
        debug.error("Compile failed", caller: self)
        print("----------------------------------------------------------------------")
    }
    
    private func analyze(cst: SyntaxTreeNode) -> Bool {
        return self.analyzer.analyze(cst)
    }
    
    private func parse(tokens: [Token]) -> Bool {
        return self.parser.parse(tokens)
        
    }
    
    private func lex() -> Bool {
        return self.lexer.lex(self.source)
    }
    
    //splits source into individual programs
    static func findPrograms(source: String) -> [Program] {
        var subSource: String = ""
        var programCount: Int = 0
        var programs: [Program] = [Program]()
        
        for char in source.characters {
            subSource = subSource + String(char)
            if char == "$" {
                programs.append(Program(source: subSource, programId: String(programCount)))
                programCount += 1
                subSource = ""
            }
        }
        return programs
    }
    
}