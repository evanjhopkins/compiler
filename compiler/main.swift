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
let debug = Debug.sharedInstance

for argument in Process.arguments {
    if argument == "-v" {
        debug.toggleVerbose(true)
    }
}

//debug.toggleVerbose(true)

let progStart = NSDate().timeIntervalSince1970 //mark time when lexer starts

for program in Program.findPrograms(source) {
    program.compile()
}

let progStop = NSDate().timeIntervalSince1970 //mark time when lexer completes
let executionTime = Int(Double(round(1000*(progStop - progStart))/1000)*1000)
print("execution time: "+String(executionTime))