//
//  DataTable.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 15/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit


/**
 * Main class that wraps bussines logic for a Sqlite Table handling
 */
public class DataTable: NSObject {
    
    
    ///Collection of DataRow objects.
    public var rows : [DataRow] = []
    ///Collection of DataColumn objects.
    public var columns : [DataColumnBase] = []
    /// Table's name
    public var name : String = ""
    public var console = Console()
    public var keyFieldName : String = ""
    
    var databasePath : String = ""
    var database : OpaquePointer? = nil
    
    /// Insert SQL statement string
    public var sqlInsert = ""
    /// Delete SQL statement string
    public var sqlDelete = ""
    /// Update SQL statement string
    public var sqlUpdate = ""
    /// Select SQL statement string
    public var sqlSelect = ""
    
    //Save record position
    var internalPosition : Int = 0
    
    /**
     * - Parameter path: Path to sqlite database file
     * - Parameter name: Table's name
     */
    public init(path: String, name: String)
    {
        self.databasePath = path
        self.name = name
        self.console.level = .ERROR
    }
    
    public override init(){
        
    }
    
    /**
     * - Returns: Returns a `DataRow` object at index given
     */
    public subscript (indexRow : Int) -> DataRow {
        get {
            return self.rows[indexRow]
        }
        
        set (row)
        {
            self.rows[indexRow] = row
        }
    }
    
    
    public subscript(indexRow: Int, key : String) -> Any {
        get {
            return self.rows[indexRow].items[key]!
        }
        
        set (value) {
            self.rows[indexRow].items[key] = value
        }
    }
    
    
    /**
     Path for sqlite file database
     */
    public var path : String {
        get {
            return self.databasePath
        }
        
        set (value) {
            self.databasePath = value
        }
    }
    
    
    
    /**
     Return the first row
     */
    public func firstRow () -> DataRow {
        return self.rows.first!
    }
    
    public func nextRow() -> DataRow? {
        var r : DataRow?
        
        if internalPosition >= self.rows.count
        { r = nil } else {
            r = self.rows[internalPosition]
            internalPosition += 1
        }
        
        return r
    }
    
    /**
     Return current row
     */
    public func currentRow() -> DataRow? {
        if !endOfRecords {
            return self.rows[self.internalPosition]
        } else {
            return nil
        }
    }
    
    /**
     Return a field from the first row
     */
    public func firstValue(field: String) -> Any? {
        return self.rows.first?[field]
        
    }
    
    
    /**
     Return next value
     */
    public func nextValue(_ field: String) -> Any? {
        var r : Any?
        if internalPosition >= self.rows.count
        {
            r = nil
        } else {
            r = self.rows[internalPosition][field]
            internalPosition += 1
        }
        return r
        
    }
    
    /**
     Return or set actually record position
     */
    public var position : Int {
        get {
            return internalPosition
        }
        
        set (value) {
            if value < self.rows.count {
                internalPosition = value
            }
        }
    }
    
    /**
     Reset pisition pointer to 0
     */
    public func reset () {
        internalPosition = 0
    }
    
    /**
     Return a boolean value that means if End Of Records has been reached.
     */
    public var endOfRecords : Bool {
        get {
            if internalPosition >= self.rows.count {
                return true
            } else {
                return false
            }
        }
    }
    
    
    
    
    public func isEmpty () -> Bool {
        if self.rows.count == 0 { return true } else { return false}
    }
    
    
    /**
     Execute a pure SQL statement string without result
     */
    public func execute(sql: String) {
        open()
        sqlite3_exec(self.database, sql, nil, nil, nil)
        close()
    }
    
    /**
     Return a single integer result from a sql query
     */
    public func intResult(sql: String) -> Int? {
        
        var query : OpaquePointer? = nil
        var r : Int32?
        
        open()
        if sqlite3_prepare(self.database, sql, -1, &query, nil) == SQLITE_OK {
            if (sqlite3_step(query)==SQLITE_ROW) {
                r = sqlite3_column_int(query, 0)
            }
        }
        sqlite3_finalize(query)
        close()
        
        if r != nil {
            return Int(r!)
        } else {
            return nil
        }
        
    }
    
    
    
    
    public func appendColumn(column: DataColumnBase) {
        console.log(message: "Appending \(column.name) column", level: .INFO)
        if column.primaryKey { self.keyFieldName = column.name }
        self.columns.append(column)
        
    }
    
    public func appendColumn(columns: DataColumnBase...) {
        for column in columns {
            self.appendColumn(column: column)
        }
    }
    
    
    public func columnBy(name: String) -> DataColumnBase {
        return self.columns.first(where: { (dc) -> Bool in
            dc.name == name
        })!
    }
    
    
    public func appendRow (_ row: DataRow)
    {
        self.rows.append(row)
    }
    
    
    func createTableSqlString() -> String {
        var sql : String = "CREATE TABLE IF NOT EXISTS \"\(self.name)\" ("
        
        
        for column in self.columns
        {
            
            sql += "\"\(column.name)\" \(column.sqliteType) "
            if column.primaryKey { sql += "PRIMARY KEY "}
            if column.autoincrement { sql += "AUTOINCREMENT "}
            if column.notNull { sql += "NOT NULL "}
            sql += ","
            
        }
        
        //Quitamos la ùltima coma
        sql.remove(at: sql.index(before: sql.endIndex))
        sql += ")"
        return sql
    }
    
    
    public func  updateSqlString (exceptColumns : DataColumnBase... ) -> String {
        return updateSqlString(exceptColumns: exceptColumns)
    }
    
    
    
    public func updateSqlString (exceptColumns : [DataColumnBase] ) -> String {
        var sql = "update \(self.name) set "
        for column in self.columns {
            // if column.name != self.keyFieldName {
            
            if !exceptColumns.contains(where: {c in c.name == column.name}) {
                sql += "\(column.name) = :\(column.name),"
            }
            //}
        }
        sql.remove(at: sql.index(before: sql.endIndex))
        
        if self.keyFieldName != "" {
            sql += " where \(self.keyFieldName) = :\(self.keyFieldName)"
        }
        
        return sql
    }
    
    public func deleteSqlString(exceptColumns : DataColumnBase...) ->String {
        let sql = "delete from \(self.name) where \(self.keyFieldName) = :\(self.keyFieldName)"
        return sql
    }
    
    
    public func insertSqlString(exceptColumns : DataColumnBase...) ->String {
        return insertSqlString(exceptColumns : exceptColumns)
    }
    
    public func insertSqlString(exceptColumns : [DataColumnBase]) ->String {
        var sql = "insert into \(self.name) ("
        
        for column in self.columns
        {
            // if column.name != self.keyFieldName {
            if !exceptColumns.contains(where: {c in c.name == column.name}) {
                sql += column.name + ","
            }
            // }
        }
        sql.remove(at: sql.index(before: sql.endIndex))
        sql += ") values ("
        
        for column in self.columns
        {
            
            // if column.name != self.keyFieldName {
            if !exceptColumns.contains(where: {c in c.name == column.name}) {
                sql += ":\(column.name),"
            }
            // }
        }
        sql.remove(at: sql.index(before: sql.endIndex))
        sql += ")"
        return sql
    }
    
    
    func selectSqlString (limit : String = "") -> String {
        
        var sql = "select  "
        for column in columns {
            sql += column.name + ","
        }
        sql.remove(at: sql.index(before: sql.endIndex))
        
        sql += " from \(self.name)"
        
        if limit != "" { sql += "limit \(limit)"}
        
        return sql
        
    }
    
    
    
    
    
    /**
     * Open a sqlite database and return a pointer to it
     */
    func open() -> Void {
        if self.database == nil {
            var db: OpaquePointer? = nil
            if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
                console.log(message: "Successfully opened connection to database at \(databasePath)", level: .INFO)
                //  return db!
            } else {
                console.log(message:"Unable to open database.", level: .ERROR)
            }
            self.database = db
        }
    }
    
    /**
     * Close database
     */
    func close() ->Void {
        sqlite3_close(self.database)
        self.database = nil
        console.log(message:"Database closed!", level: .INFO)
    }
    
    /**
     * Read metadata from a table in sqlite and configure actual DataTable with this information
     * ---
     * It should be used when they have not built the columns manually.
     */
    func inferStructure() {
        let sql = "PRAGMA table_info (\(self.name))"
        
        var query : OpaquePointer? = nil
        
        open()
        if sqlite3_prepare(self.database, sql, -1, &query, nil) == SQLITE_OK {
            while (sqlite3_step(query)==SQLITE_ROW) {
                
                let name = String(cString: sqlite3_column_text(query, 1))
                let typeName = String(cString: sqlite3_column_text(query, 2))
                let notNull = sqlite3_column_int(query, 3)
                let primaryKey = sqlite3_column_int(query, 5)
                let column : DataColumnBase
                
                
                
                switch typeName {
                case "TEXT":
                    column = DataColumnString (name)
                    break
                    
                case "INTEGER":
                    column = DataColumnInteger (name)
                    break
                    
                case "REAL":
                    column = DataColumnDouble (name)
                    break
                    
                case "BLOB":
                    column = DataColumnBlob(name)
                    break
                    
                default:
                    column = DataColumnString (name)
                    break
                    
                }
                if notNull == 1 { column.notNull = true }
                if primaryKey == 1 {column.primaryKey = true; self.keyFieldName = name }
                
                self.columns.append(column)
                
            }
        }
        close()
    }
    
    /**
     * Create a sqlite table in database
     */
    public func create() {
        var query : OpaquePointer? = nil
        open()
        let sql = createTableSqlString()
        if sqlite3_prepare_v2(self.database,sql, -1, &query, nil) == SQLITE_OK {
            if sqlite3_step(query) == SQLITE_DONE {
                console.log(message:"Create table \(self.name)", level: .INFO)
                console.log(message:sql, level: .WARNING)
                
                
            } else {
                let errmsg = String(cString: sqlite3_errmsg(self.database))
                console.log(message:"Error creating  table \(self.name). \(errmsg)", level: .ERROR)
                
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(self.database))
            console.log(message:"Error creating  table \(self.name). \(errmsg)", level: .ERROR)
            
            
        }
        close()
    }
    
    /**
     * Drop a table in database
     * ---
     * The table dropped is the same declared as parameter of DataTable name
     */
    public func drop() {
        var query : OpaquePointer? = nil
        open()
        if sqlite3_prepare_v2(self.database, "drop table if exists \"\(self.name)\"", -1, &query, nil) == SQLITE_OK {
            if sqlite3_step(query) == SQLITE_DONE {
                console.log(message:"Drop table \(self.name)", level: .INFO)
                
            } else {
                let errmsg = String(cString: sqlite3_errmsg(self.database))
                console.log(message:"Error dropping  table \(self.name). \(errmsg)", level: .ERROR)
                
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(self.database))
            console.log(message:"Error dropping  table \(self.name). \(errmsg)", level: .ERROR)
            
            
        }
        sqlite3_finalize(query)
        close()
    }
    
    
    
    
    public func showColumnsStructure() -> String  {
        var r = ""
        for column in self.columns {
            r += column.show()
            r += "\n---\n"
        }
        return r
    }
    
    
    /**
     * Create new DataRow object with status INSERTED
     */
    public func newRow () -> DataRow {
        let r = DataRow(self)
        r.status = .INSERTED
        return r
    }
    
    /**
     * Insert a new DataRow into DataTable object with `status` set to `.INSERTED`
     * - Returns: Return the DataRow created
     */
    public func insertRow () -> DataRow {
        let r = self.newRow()
        r.status = .INSERTED
        self.rows.append(r)
        return r
    }
    
    /**
     * Insert a new DataRow into DataTable object with `status` set to `.INSERTED`.
     * - Parameter values: A dictionary object with tuple Key (field's name) and value.
     * - Returns: Return the DataRow created
     */
    public func insertRow (_ values : [String : Any]) -> Void {
        let dr = self.newRow()
        dr.items.removeAll()
        for key in values.keys {
            dr.items[key] = values[key]
        }
        dr.status = .INSERTED
        self.rows.append(dr)
        console.log(message: "Appending row", level: .INFO)
    }
    
    
    /**
     * Remove all rows on this DataTable
     */
    public func clearRows() {
        self.rows.removeAll()
    }
    
    public func clear() {
        clearRows()
        self.columns.removeAll()
    }
    
    
    /**
     Return the number of rows
     */
    public func count() -> Int {
        return self.rows.count
    }
    
    /**
     Return count of all records
     Like:
     ```
     select count(*) from myTable
     ```
     - Returns: Integer with count of all records avalibles
     */
    public func countAllRecords () -> Int {
        var query : OpaquePointer? = nil
        var r : Int32 = -1
        open()
        
        let sql = "select count(*) from \(self.name)"
        
        if sqlite3_prepare_v2(self.database, sql, -1, &query, nil) == SQLITE_OK {
            if sqlite3_step(query) == SQLITE_ROW {
                console.log(message:"Counting records \(self.name)", level: .INFO)
                r = sqlite3_column_int(query, 0)
                
            } else {
                let errmsg = String(cString: sqlite3_errmsg(self.database))
                console.log(message:"Error counting records: table \(self.name). \(errmsg)", level: .ERROR)
                print(sql)
                
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(self.database))
            console.log(message:"Error counting records: table \(self.name). \(errmsg)", level: .ERROR)
        }
        
        sqlite3_finalize(query)
        close()
        return Int(r)
        
    }
    
    /**
     * Load data from swlite to DataTable object. If the sql parameter is used then self.selectSql is obviated.
     */
    @discardableResult
    public func load(sql: String = "") -> DataTable {
        
        //El puntero de posición de registro lo pasamos a 0
        self.reset()
        
        //Si no hay columnas las inferimos
        if sql == "" && self.columns.count == 0 {
            self.inferStructure()
        }
        
        //Cargamos la instrucción sql por defecto si no se proporciona una
        if sql == "" { self.sqlSelect = selectSqlString() } else { self.sqlSelect = sql}
        
        //Abrimos
        open()
        
        // puntero
        var query : OpaquePointer? = nil
        
        //Preparamos la sentecia
        if sqlite3_prepare_v2(self.database, self.sqlSelect, -1, &query, nil)  == SQLITE_OK {
            
            //Cargamos cada fila
            while (sqlite3_step(query)==SQLITE_ROW) {
                
                let row = DataRow(self)
                
                for n in 0 ... sqlite3_column_count(query) - 1 {
                    
                    let columnName = String(cString: sqlite3_column_name(query, n))
                    let column = self.columns.first(where: {$0.name == columnName})!
                    console.log(message:"Loading by column \(columnName), \(n)", level: .INFO)
                    row.items[columnName] = column.value(query: query!, index:n)
                    
                }
                self.rows.append(row)
            }
            
            
            
        } else {
            let errmsg = String(cString: sqlite3_errmsg(self.database))
            console.log(message:"Error loading  table \(self.name). \(errmsg)", level: .ERROR)
            
        }
        
        close()
        
        return self
        
    }
    
    
    
    /**
     Process all changes pending into rows.
     This method read status property of each row and execute sql code for them.
     */
    public func update(exceptColumns: DataColumnBase... ){
        update(exceptColumns: exceptColumns)
    }
    
    /**
     Process all changes pending into rows.
     This method read status property of each row and execute sql code for them.
     */
    public func update(exceptColumns: [DataColumnBase]) {
        
        if self.sqlInsert ==  "" { self.sqlInsert = insertSqlString(exceptColumns: exceptColumns) }
        if self.sqlDelete ==  "" { self.sqlDelete = deleteSqlString() }
        if self.sqlUpdate ==  "" { self.sqlUpdate = updateSqlString(exceptColumns: exceptColumns) }
        
        open()
        
        var sql = ""
        
        for row in rows
        {
            switch row.status {
                
            case .NORMAL:
                break
                
            case .INSERTED:
                sql = self.sqlInsert
                break
                
            ///TODO:
            case .DELETED:
                sql = self.sqlDelete
                break
            ///TODO:
            case .UPDATED:
                sql = self.sqlUpdate
                break
                
            }
            
            
            var query : OpaquePointer? = nil
            
            if row.status != .NORMAL {
                if sqlite3_prepare_v2(self.database, sql, -1, &query, nil) == SQLITE_OK {
                    
                    console.log(message:"Proccessing \(sql)", level: .INFO)
                    
                    
                    var n : Int32 = 1
                    for column in columns {
                        
                        if !exceptColumns.contains(where: {c in c.name == column.name}) {
                            
                            let columnName = column.name
                            let value = row.items[columnName]
                            
                            console.log(message: columnName, level: .INFO)
                            console.log(message: String(describing: value), level: .INFO)
                            
                            if value != nil {
                                column.value(query: query!, index: n, newValue: value!)
                            }
                            
                            n += 1
                        }
                    }
                    
                    
                    
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(self.database))
                    console.log(message:"Error inserting  row \(self.name). \(errmsg)", level: .ERROR)
                    console.log(message:self.sqlInsert, level: .WARNING)
                    
                }
                
                
                if sqlite3_step(query) == SQLITE_DONE {
                    console.log(message: "Proccessed...", level: .INFO)
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(self.database))
                    console.log(message:"Error inserting  row  \(self.name). \(errmsg)", level: .ERROR)
                }
                
            }
            sqlite3_finalize(query)
            row.status = .NORMAL
        }
        close()
        
        self.sqlInsert = ""
        self.sqlUpdate = ""
        self.sqlDelete = ""
    }
    
    
    
    /**
     Merge into this table rows from dataTable parameter, including all fields excepts declared as exceptDataColumns
     */
    public func merge(dataTable: DataTable, exceptColumns : DataColumnBase...) {
        
        self.sqlInsert = insertSqlString(exceptColumns: exceptColumns)
        
        for row in dataTable.rows {
            /*
             let r = self.newRow()
             for column in self.columns {
             
             
             if !exceptDataColumns.contains(where: {c in c.name == column.name}) {
             r[column.name] = row[column.name]
             }
             }
             self.rows.append(r)
             */
            row.status = .INSERTED
            self.rows.append(row)
            
        }
        
    }
    
    
    
    /**
     * Extract an array with elements from a field
     */
    public func extract (field: String ) -> [Any] {
        var r : [Any] = []
        for row in self.rows {
            r.append(row.items[field]!)
        }
        return r
    }
    
    
    
    /**
     * Return a DataTable object with same initial parameters, path and name
     */
    public func newInstance(newPath:String? = nil) -> DataTable {
        let path = newPath ?? self.databasePath
        
        let dt = DataTable(path: path, name: self.name)
        dt.columns = self.columns
        return dt
    }
    
    
    public func show() -> String {
        var r = "Table \(self.name)\n"
        for row in rows {
            for column in columns {
                r += "\t\(column.name) : \(row.items[column.name]!)\n"
            }
            r+="--\n"
        }
        return r
    }
    
    
    /**
     * Generate a JSON String with built in data.
     */
    public func toJSON() -> String {
        var r : String =  "{\n\t\"\(self.name)\":[\n"
        
        for row in self.rows{
            
            r += "\t\t{"
            
            for col in self.columns {
                
                let field = col.jsonSerialize(object: row.items[col.name]!)!
                r += "\"\(col.name)\":\"\(field)\","
                
            }
            r.characters.removeLast()
            r += "},\n"
        }
        r.characters.remove(at: r.index(r.endIndex, offsetBy: -2))
        r += "\t]\n}"
        return r
        
    }
    
    
    /**
     * Read a JSON string and convert it into data that fill a DataTable object.
     * Before read a JSON file it is neccesary create a DataTable object with columns defined.
     * Try to fill a DataTable without columns will return an errror.
     */
    public func fromJSON (jsonString: String) {
        
        let data = jsonString.data(using: .utf8)!
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let root = json as? [String: Any] {
                //  let tableName = root.keys.first!
                if let jsonRows = root.values.first as? [Any] {
                    for jsonRow in jsonRows {
                        let row = DataRow(self)
                        if let jsRow = jsonRow as? [String : Any] {
                            for col in self.columns {
                                let value = jsRow[col.name] as! NSString
                                row.items[col.name] = col.jsonDeserialize(code: value)!
                            }
                        }
                        self.rows.append(row)
                    }
                }
            }
            
        } catch  let error as NSError  {
            console.log(message: error.localizedDescription, level: .ERROR)
        }
        
    }
    
    
    
    
}



