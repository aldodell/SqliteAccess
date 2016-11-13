//
//  DataTableBinding.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 5/11/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataTableBinding: NSObject {
    
    public struct Bond {
        public var toView : (Any)->Void
        public var toDataTable : (Void) -> Any
        
    }
    
    public var bindings : [String : Bond] = [:]
    public var dataTable : DataTable? = nil
    
    
    public init (_ dataTable: DataTable) {
        self.dataTable = dataTable
    }
    
    
    
    public func bind(toView : @escaping (Any)->Void, toDataTable: @escaping (Void)->Any, field: String) {
        let b = Bond(toView: toView, toDataTable: toDataTable)
        self.bindings[field] = b
        
    }
    
    public func syncViews(indexRow: Int) {
        if let row = self.dataTable?.rows[indexRow] {
            for field in self.bindings.keys {
                self.bindings[field]?.toView(row[field])
            }
        }
    }
    
    public func syncDataTable(_ row : DataRow){
        for field in self.bindings.keys {
            row[field] = self.bindings[field]!.toDataTable()
            row.status = .UPDATED
        }
        
    }
    
    
    
    
}
