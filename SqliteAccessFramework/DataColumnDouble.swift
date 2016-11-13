//
//  DataColumnDouble.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit


public class DataColumnDouble: DataColumnBase {
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
        sqlite3_bind_double(query, index, newValue as! Double)
        
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        return sqlite3_column_double(query, index)
    }
    
    override func jsonDeserialize(code: NSString) -> Any? {
        return code.doubleValue
    }
    
    override func jsonSerialize(object: Any) -> Any? {
        return String(object as! Double)
        
    }

     
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .REAL
    }


}
