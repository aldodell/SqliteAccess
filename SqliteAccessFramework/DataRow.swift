//
//  DataRow.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 15/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataRow: NSObject {
    public var items : [String : Any] = [:]
    public var status : SqliteAccessRowStatus = .NORMAL
    public weak var dataTable : DataTable?
    
    public init(_ dt: DataTable) {
        self.dataTable = dt
    }
    
    /**
     * Change values of this DataRow and set status to .UPDATE
     */
    public func update(_ values: [String:Any]){
        for key in values.keys {
            self.items[key] = values[key]
        }
        self.status = .UPDATED
    }
    
    public func delete() {
        self.status = .DELETED
    }
    
    public subscript (key : String) -> Any {
        get {
            return self.items[key]
        }
        
        set (value) {
            self.items[key] = value
        }
        
    }
    
    
}
