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
    
    init(source: String, programId: String) {
        self.source = source
        self.programId = programId
    }
    
    func compile() {
        debug.affirm("Compiling program "+String(self.programId), caller: self)
        parse(lex())
        debug.affirm("Compile completed\n", caller: self)
    }
    
    private func parse(tokens: [Token]) {
        let parser = Parser(tokens: tokens)
        parser.parser()
    }
    
    private func lex() -> [Token] {
        let lexer = Lexer()
        let tokens: [Token] = lexer.lex(self.source)
        return tokens
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