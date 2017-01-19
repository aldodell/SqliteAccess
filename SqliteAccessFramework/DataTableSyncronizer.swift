//
//  DataTableSyncronizer.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 19/1/17.
//  Copyright © 2017 Aldo Dell. All rights reserved.
//

import UIKit

public class DataTableSyncronizer: NSObject {
    
    ///Store a reference to a DataTable object
    public var dataTable : DataTable
    
    
    ///Syncronize with this DataTable
    public init(_ dataTable: DataTable) {
        self.dataTable = dataTable
    }
    
    
    ///Store a clousure wich is called for update views associated with this DataTable
    public var updateViews : ((DataRow) -> ())? = nil
    ///Store a clousure wich update a specific row from views associated with this DataTable
    public var updateModel : ((DataRow)->())? = nil
    
    ///Position of row pointer
    public var position : Int = 0
    
    
    ///Return if is reached end of records
    public func endOfRecords() -> Bool {
        return self.position >= self.dataTable.rows.count
    }
    
    ///Set to 0 the internal row pointer
    public func reset() {
        self.position = 0
    }
    
    /// search first row and update views
    public func first() {
        self.position = 0
        updateViews!(dataTable.rows[self.position])
        
    }
    
    /// search next row and update views. If end of records is reached return false
    public func next() -> Bool {
        self.position = self.position + 1
        let r = !endOfRecords()
        if r {
            updateViews!(dataTable.rows[self.position])
            
        }
        return r
    }
    
    ///Get data from view, create a new row and insert into DataTable
    public func insert() {
        updateModel!(self.dataTable.insertRow())
    }
    
    ///Get data from view, update a  row
    public func update() {
        updateModel!(self.dataTable.rows[self.position])
    }
    
    
}
