//
//  DataColumnInteger.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnInteger: DataColumnBase {
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
        sqlite3_bind_int(query, index, newValue as! Int32)
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        return sqlite3_column_int(query, index)
    }
    
    override func jsonDeserialize(code: NSString) -> Any? {
        return code.intValue
    }
    
    override func jsonSerialize(object: Any) -> Any? {
        return String(object as! Int32)
        
    }
    
    
    
    
    
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .INTEGER
    }
    
   


}
