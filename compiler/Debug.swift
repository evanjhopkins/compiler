//
//  Debug.swift
//  compiler
//
//  Created by Evan Hopkins on 2/24/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

class Debug: CompilerComponentProtocol {
    var CLASSNAME = "DEBUG"
    static let sharedInstance = Debug()
    var log: [JSON] = []
    var verbose = false
    
    init(){
    }
    
    func toggleVerbose(isVerboseOn: Bool) {
        self.verbose = isVerboseOn
        self.affirm("Running in " + (self.verbose ? "verbose" : "non-verbose") + " mode\n", caller: self)
    }
    
    func error(message: String, caller: CompilerComponentProtocol) {
        let log = Log(componentName: caller.CLASSNAME, message: message, level: LogLevel.ERROR)
        self.log.append(log.serialize())
        log.display()
    }
    
    func warn(message: String, caller: CompilerComponentProtocol) {
        let log = Log(componentName: caller.CLASSNAME, message: message, level: LogLevel.WARN)
        self.log.append(log.serialize())
        log.display()
    }

    func log(message: String, caller: CompilerComponentProtocol) {
        let log = Log(componentName: caller.CLASSNAME, message: message, level: LogLevel.LOG)
        self.log.append(log.serialize())
        if verbose {
            log.display()
        }
    }
    
    func affirm(message: String, caller: CompilerComponentProtocol) {
        let log = Log(componentName: caller.CLASSNAME, message: message, level: LogLevel.AFFIRM)
        self.log.append(log.serialize())
        log.display()
    }
    
    func getSerializedLog() -> String {
        let json = JSON(self.log)
        let paramsString = json.rawString(NSUTF8StringEncoding, options: [])
        return paramsString!
    }
}

class Log{
    let componentName: String
    let message: String
    let level: LogLevel
    
    init(componentName: String, message: String, level: LogLevel) {
        self.componentName = componentName
        self.message = message
        self.level = level
    }
    
    func serialize() -> JSON {
        var dict: [String: String] = [String: String]()
        dict["component"] = componentName
        dict["message"] = message
        dict["level"] = String(level)
        
        let json = JSON(dict)
        return json
    }
    func display() {
        print(componentName + ": "+message)
    }
}

enum LogLevel{
    case AFFIRM
    case ERROR
    case WARN
    case LOG
}
