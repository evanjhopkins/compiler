//
//  main.swift
//  compiler
//
//  Created by Evan Hopkins on 1/28/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

let lexer = Lexer()

let userInput = "{ if (5==(2==\"word with space\")) }"

let tokens: [Token] = lexer.lex(userInput)

let parser = Parser(tokenss: tokens)

parser.parse()

