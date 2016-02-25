//
//  main.swift
//  compiler
//
//  Created by Evan Hopkins on 1/28/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

let lexer = Lexer()

let userInput = "{ if (5==8) }"

let tokens: [Token] = lexer.getLexy(userInput)

let parser = Parser(tokenss: tokens)

parser.parse()

