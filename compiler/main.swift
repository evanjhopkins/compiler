//
//  main.swift
//  compiler
//
//  Created by Evan Hopkins on 1/28/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

let stdin = NSFileHandle.fileHandleWithStandardInput()

let source = NSString(data: stdin.availableData, encoding: NSUTF8StringEncoding) as! String

let lexer = Lexer()

let tokens: [Token] = lexer.lex(source)

let parser = Parser(tokens: tokens)

parser.parse()

let debug = Debug.sharedInstance
