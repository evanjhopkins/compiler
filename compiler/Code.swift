//
//  Code.swift
//  compiler
//
//  Created by Evan Hopkins on 5/9/16.
//  Copyright © 2016 evanjhopkins. All rights reserved.
//

import Foundation

struct DataRecord {
    var tempId: String
    var varId: String?
    var addr: Int?
    var scope: Int
    var type: String
}

struct JumpRecord {
    var tempId: String
    var distance: Int?
}

class Code {
    
    var scope: Int
    
    //tempId -> record
    var jumpTable: [String : JumpRecord]
    var dataTable: [String : DataRecord]
    
   // let ast: SyntaxTreeNode
    
    var code: String
    var heap: String
    
    init() {
        jumpTable = [String : JumpRecord]()
        dataTable = [String : DataRecord]()
        //self.ast = ast
        self.code = ""
        self.heap = ""
        self.scope = 0
    }
    
    func generateCode(ast: SyntaxTreeNode) -> String {
        routeNode(ast)
        backpatch()
        self.code += "00"
        
        let filler = 256 - (self.code.characters.count/2) - (self.heap.characters.count/2)
        return self.code + String(count: filler*2, repeatedValue: Character("0")) + self.heap
    }
    
    func backpatch() {
        for entry in dataTable {
            let dataRecord = entry.1
            let staticBlock = findNextStaticMemBlock() + "00"//pad & little endian
            self.code = self.code.stringByReplacingOccurrencesOfString(dataRecord.tempId, withString: staticBlock)
        }
    }
    
    func findNextStaticMemBlock() -> String {
        var hexId:String = String(format:"%2X", (self.code.characters.count+2)/2)
        hexId = hexId.stringByReplacingOccurrencesOfString(" ", withString: "0")
        //fill new block with empty data
        self.code += "00"
        return hexId
    }
    
    func routeNode(ast: SyntaxTreeNode) {
        switch (ast.value!) {
            case "BLOCK":
                //advance scope
                self.scope = self.scope + 1
                //route children
                for child in ast.children {
                    routeNode(child)
                }
                self.scope = self.scope - 1
            case "Variable Declaration":
                handleVarDecl(ast)
            case "Assignment Statement":
                handleAssignmentStatement(ast)
            case "Print Statement":
                handlePrintStatement(ast)
            default:
                return
        }
    }
    
    func handleVarDecl(ast: SyntaxTreeNode) {
        //assume int for now
        var code = "A9"+"00"+"8D"
        let tempId = getNewTempId()
        //create dataTable entry
        let type = ast.children[0].value!
        let varId = ast.children[1].value
        
        //create an entry in the static dataTable
        self.dataTable[tempId] = DataRecord(tempId: tempId, varId: varId, addr: self.dataTable.count+1 , scope: self.scope, type: type)
        //append the temp id to the base machine code: "A9 00 8D" + "TX 00"
        code += tempId
    
        if type=="string"{
         return//dont add code for string
        }
        self.code += code
    }
    
    func handleAssignmentStatement(ast: SyntaxTreeNode) {
//        if !ast.children[1].isLeaf {
//            var value = resolveIntExpr(ast)
//        }
        
        
        var code = "A9"
        let varId = ast.children[0].value!
        var value = ast.children[1].value!
        if value=="true"{
            value = String(1)
        }else if value=="false"{
            value = String(0)
        }
        let dataRecord = getDataRecordForVarId(varId, scope: self.scope)!

        if dataRecord.type=="string" {
            //remove quotes from beginning and end of string
            value = String(value.characters.dropFirst())
            value = String(value.characters.dropLast())
            
            var hexString = ""
            for c in value.characters {
                hexString += String(format:"%2X", (String(c) as NSString).characterAtIndex(0))
            }
            hexString += "00"//terminator
            //prepend to heap
            self.heap = hexString + self.heap
            let memId = String(format:"%2X", ( (512 - heap.characters.count) / 2))
            code += memId
            
        }else{
            //load accumulator with value
            code += padNum(value)
        }
        code += "8D"
        code += dataRecord.tempId
        self.code += code
    }
    
    func handlePrintStatement(ast: SyntaxTreeNode) {
        var code = "AC"
        
        var varId = ast.children[0].value!
        
        //handle raw string
        if varId.characters.first == "\"" {
            //drop quotes
//            varId = String(varId.characters.dropFirst())
//            varId = String(varId.characters.dropLast())
            
            let simulatedNode = SyntaxTreeNode()
            simulatedNode.addLeaf("@")
            simulatedNode.addLeaf(varId)
            //add mem entry
            let tempId = getNewTempId()
            self.dataTable[tempId] = DataRecord(tempId: tempId, varId: "@", addr: self.dataTable.count+1 , scope: self.scope, type: "string")
            handleAssignmentStatement(simulatedNode)
            
            varId = "@"
        }
        
        //load Y register with contents of A, TX 00
        let dataRecord = getDataRecordForVarId(varId, scope: self.scope)!
        code += dataRecord.tempId
        
        code += "A2"
        code += dataRecord.type=="string" ? "02":"01"
        code += "FF"
        
        self.code += code
    }
    
    func padNum(num: String) -> String {
        var strNum = num
        if strNum.characters.count < 2 {
            strNum =  "0"+strNum
        }
        return strNum
    }
    
    func getDataRecordForVarId(varId: String, scope: Int) -> DataRecord? {
        for rec in self.dataTable {
            if rec.1.varId==varId && rec.1.scope==scope{
                return rec.1
            }
        }
        if scope > 0 {
            return getDataRecordForVarId(varId, scope: scope-1)
        }
        print("ERROR GETTING DATA RECORD")
        return nil
    }
    
    func getNewTempId() -> String {
        return "T"+String(self.dataTable.count)+"XX"
    }
}