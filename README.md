# SqliteAccess
Other sqlite framework based on Data Table logic
-
This is another sqlite framework for iOS. The main idea is join all database logic into a unique instance of DataTable object that open, manage and close connections with sqlite and all it's data.
Each DataTable object represents a table into a sqlite database.

# Use
In swift: 

```swift
let dt = DataTable(path: "/path/to/database.sqlite", name: "myTable")
```

# Undersanting DataTable object
A DataTable object contains several objects that perform all database operations for you.
At glance, we have a DataRow array with all rows of you sql query.

There are several DataColumn thats represents each column on the table.

```swift
 flightDataTable = DataTable(path: flightDatabasePath, name: "flights")
        let id = DataColumnInteger("id")
        let callsign = DataColumnString("callsign")
        let aircraftType =  DataColumnString("aircraftType")
        let route = DataColumnString("route")
        let hours = DataColumnDouble("hours")
        let date = DataColumnDate("date")
        let customer = DataColumnString("customer")
        let notes = DataColumnString("notes")
      
         //editing id
        id.notNull = true
        id.autoincrement = true
        id.primaryKey = true
        id.unique = true
        
        flightDataTable.keyFieldName = "id"
        
        //Append columns
        flightDataTable.appendColumn(columns: id,callsign,aircraftType,route,hours,date,customer,notes)
       
        //if not exists table, create it
        flightDataTable.create()
```

