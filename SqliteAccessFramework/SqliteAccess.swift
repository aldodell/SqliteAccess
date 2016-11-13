//
//  SqliteAccess.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 16/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import Foundation

public enum SqliteType : String {
    case TEXT = "TEXT"
    case INTEGER = "INTEGER"
    case REAL = "REAL"
    case BLOB = "BLOB"
    
}

public enum SqliteAccessRowStatus {
    case NORMAL
    case INSERTED
    case UPDATED
    case DELETED
}

public func documentPath(addFile: String) -> String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(addFile)"
    
}


public class Console {
    public enum MESSAGE_LEVEL : Int32
    {
        case NOTHING = 0
        case ERROR = 1
        case WARNING = 2
        case INFO = 4
        case ALL = 8
    }
    
    public var level : MESSAGE_LEVEL = .ERROR
    
    public func log (message : String, level: MESSAGE_LEVEL = .INFO) {
        if level.rawValue >= self.level.rawValue {
            print(message)
        }
    }
}



