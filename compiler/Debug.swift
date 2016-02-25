//
//  Debug.swift
//  compiler
//
//  Created by Evan Hopkins on 2/24/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Debug{
    static let verbose: Bool = true
    
    init(verbose: Bool) {
       // self.verbose = verbose
    }
    
    static func error(message: String, caller: CompilerComponentProtocol) {
        if verbose{
            print("[Error]["+caller.CLASSNAME+"] " + message)
        }
    }
    
    static func warn(message: String, caller: CompilerComponentProtocol) {
        if verbose{
            print("[Warn]["+caller.CLASSNAME+"] " + message)
        }
    }

    static func log(message: String, caller: CompilerComponentProtocol) {
        if verbose{
            print("[Log]["+caller.CLASSNAME+"] " + message)
        }
    }

    
}