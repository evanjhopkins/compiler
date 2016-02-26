//
//  main.swift
//  compiler
//
//  Created by Evan Hopkins on 1/28/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

let lexer = Lexer()

let userInput = "{ print ( 5 ) }"

let tokens: [Token] = lexer.lex(userInput)

let parser = Parser(tokens: tokens)

parser.parse()

let debug = Debug.sharedInstance
//print(debug.getSerializedLog())

