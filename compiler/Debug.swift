//
//  Debug.swift
//  compiler
//
//  Created by Evan Hopkins on 2/24/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Debug{
    
    static func error(message: String, caller: CompilerComponentProtocol) {
        //errors always log
        print("[Error]["+caller.CLASSNAME+"] " + message)
    }
    
    static func warn(message: String, caller: CompilerComponentProtocol) {
        if caller.VERBOSE {
            print("[Warn ]["+caller.CLASSNAME+"] " + message)
        }
    }

    static func log(message: String, caller: CompilerComponentProtocol) {
        if caller.VERBOSE {
            print("[Log  ]["+caller.CLASSNAME+"] " + message)
        }
    }
    
    static func affirm(message: String, caller: CompilerComponentProtocol) {
        //affirms always log
        print("[Affirm]["+caller.CLASSNAME+"] " + message)
    }
}