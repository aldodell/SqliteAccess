//
//  DataColumnString.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnDate: DataColumnBase {
    let formatter  = DateFormatter()
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
       let d = newValue as! Date
        let s = formatter.string(from: d)
        let ns = NSString(string: s)
        sqlite3_bind_text(query, index, ns.utf8String, -1, nil)
        
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        let r = String(cString: sqlite3_column_text(query, index))
        let d = formatter.date(from: r)!
        return d
    }
    
    override func jsonDeserialize(code: NSString) -> Any? {
        let date = formatter.date(from: String(code))
        return date
    }
    
    override func jsonSerialize(object: Any) -> Any? {
        return formatter.string(from: object as! Date)
    }
    
    
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .TEXT
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
}
