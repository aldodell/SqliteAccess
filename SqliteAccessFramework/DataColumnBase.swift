//
//  DataColumnBase.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnBase {
    
    
    public var name : String
    public var primaryKey: Bool = false
    public var autoincrement : Bool = false
    public var unique : Bool = false
    public var notNull : Bool = false
    public var sqliteType : SqliteType = .TEXT
   
    required public init(_ name: String)
    {
        self.name = name
        
    }
    
    
    
   public  init(name: String, primaryKey : Bool = false, autoincrement : Bool = false, unique : Bool = false, notNull : Bool = false)
    {
        self.name = name
        self.unique = unique
        self.autoincrement = autoincrement
        self.notNull = notNull
        self.primaryKey = primaryKey
        
    }
    
    
  public  func show () -> String {
        
        let s = "DataColumn \n name: \(self.name) \n type: \(self.sqliteType) \n sqlite type: \(self.sqliteType) \n primaryKey: \(self.primaryKey) \n unique: \(self.unique) \n autoincrement: \(self.autoincrement) \n notNull: \(self.notNull) \n"
        
        return s
        
    }
    
    
    /**
     * Get a String from aq query
     */
    func  value (query: OpaquePointer, index : Int32) -> Any? {
        return nil
    }
    
    /**
     * Bind a String value with DataBase
     */
    func value(query: OpaquePointer, index : Int32, newValue : Any) {
        
    }
    
    
    
    
    func jsonDeserialize(code: NSString) -> Any? {
        return String(code)
    }
    
    func jsonSerialize(object: Any) -> Any? {
        return nil
    }
    
    
    
}
