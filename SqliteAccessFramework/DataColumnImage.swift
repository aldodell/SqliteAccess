//
//  DataColumnImage.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 26/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import UIKit

public class DataColumnPNGImage: DataColumnBase {
    
    override func value(query: OpaquePointer, index: Int32, newValue: Any) {
        
        let image = newValue as! UIImage
        let imageData : NSData = UIImagePNGRepresentation(image)! as NSData
        
        
        
        sqlite3_bind_blob(query, index, imageData.bytes, Int32(imageData.length), nil)
    }
    
    override func value(query: OpaquePointer, index: Int32) -> Any {
        
        let bytes = sqlite3_column_blob(query, index)
        let length = sqlite3_column_bytes(query, index)
        let data = NSData(bytes: bytes, length: Int(length))
        let image = UIImage(data: data as Data)
        return image!
        
    }
    
      
    
    
    override func jsonDeserialize(code: NSString) -> Any? {
        var image : UIImage?
        if  let data = Data(base64Encoded: String(code)) {
            image = UIImage(data: data)
        }
        return image
    }
  
    
    
    override func jsonSerialize(object: Any) -> Any? {
        let imageData : NSData = UIImagePNGRepresentation(object as! UIImage)! as NSData
        return imageData.base64EncodedString(options: .init(rawValue: 0))
      
    }
    
    
    
    required public init(_ name: String) {
        super.init(name)
        self.sqliteType = .BLOB
    }
    
    
}



