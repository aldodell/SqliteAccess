//
//  DataColumnString.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnString: DataColumnBase {
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
        
        let ns = NSString(string: newValue as! String)
        sqlite3_bind_text(query, index, ns.utf8String, -1, nil)
        
        
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        let r = String(cString: sqlite3_column_text(query, index))
        return r
    }
    
    override func jsonDeserialize(code: NSString) -> Any? {
        return String(code)
    }

    override func jsonSerialize(object: Any) -> Any? {
        return object
    }

    
    
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .TEXT
    }
    
    
    
    
}
