//
//  DataTableSyncronizer.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 19/1/17.
//  Copyright © 2017 Aldo Dell. All rights reserved.
//

import UIKit



/**
 This class allow to update views or data in a DataTable object.
 It is neccesary pass a DataTable object with will be used but this syncronizer
 
 ```swift
 let sync = DataTableSyncronizer(dataTable)
 
 // For update views
 sync.updateViews = {
 row in
 nameTextField.text = row["name"]
 }
 
 // For update the model (or a row in DataTable object)
 sync.updateModel = {
 row in
 row["name"] = nameTextField.text
 }
 
 //For clears views
 sync.clearViews = {
 nameTextField.text = ""
 }
 
 //Move to first record:
 sync.first()
 //Move to next record:
 while sync.next() {
 ...
 }
 
 ```
 */
public class DataTableSyncronizer: NSObject {
    
    ///Store a reference to a DataTable object
    public var dataTable : DataTable
    
    
    ///Syncronize with this DataTable
    public init(_ dataTable: DataTable) {
        self.dataTable = dataTable
    }
    
    
    /**
     Store a clousure wich is called for update views associated with this DataTable
     */
    public var updateViews : ((DataRow) -> ())? = nil
    
    /**
     Store a clousure wich update a specific row from views associated with this
     DataTable.
     It's possible to do any action with the row before return it to DataTable object.
     So changes into fields may be programmatically instead fetching from views.
     */
    public var updateModel : ((DataRow)->())? = nil
    
    ///Store a clousure wich clear all views
    public var clearViews : (()->())? = nil
    
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
        if let uv = self.updateViews {
            uv(dataTable.rows[self.position])
        }
        
    }
    
    /**
     search next row and update views.
     - Returns: If end of records is reached return false
     */
    public func next() -> Bool {
        self.position = self.position + 1
        let r = !endOfRecords()
        if r {
            if let uv = self.updateViews {
                uv(dataTable.rows[self.position])
            }
        }
        return r
    }
    
    /**
     Get data from view, create a new row and insert into DataTable
     - Returns: Return a boolean wich indicate if succesfull
     */
    @discardableResult
    public func insert() -> Bool {
        if let um = updateModel {
            um(self.dataTable.insertRow())
            return true
        }
        return false
    }
    
    /**
     Get data from view, update a  row
     - Returns: Return a boolean wich indicate if succesfull
     */
    @discardableResult
    public func update() -> Bool {
        if let um = updateModel {
            um(self.dataTable.rows[self.position])
            return true
        }
        return false
    }
    
    
}
