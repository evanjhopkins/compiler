//
//  main.swift
//  compiler
//
//  Created by Evan Hopkins on 1/28/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

let lexer = Lexer()



func input() -> String {
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    return NSString(data: inputData, encoding: NSUTF8StringEncoding) as! String
}

print("Please paste source:")
let source = input()
print("\(source)")

let tokens: [Token] = lexer.lex(source)

let parser = Parser(tokens: tokens)

parser.parse()

let debug = Debug.sharedInstance
    