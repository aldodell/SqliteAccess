//
//  DataColumnBlob.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnBlob: DataColumnBase {
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
        sqlite3_bind_blob(query, index, newValue as! UnsafeRawPointer, -1, nil)
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        return  sqlite3_column_blob(query, index)
        
    }
    
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .BLOB
    }
    
   
    
    override func jsonDeserialize(code: NSString) -> Any? {
        return String(code)
    }

    override func jsonSerialize(object: Any) -> Any? {
        return object
        
    }
    
    
}
