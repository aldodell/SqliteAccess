//
//  extensions.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 17/1/17.
//  Copyright © 2017 Aldo Dell. All rights reserved.
//

import UIKit

/**
 Return a String representation from a Date object
 */
public extension Date {
   public func toString(format: String = "dd/MM/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}



/**
 Helps to dismisss the keyboard
 */
public extension UIViewController {
    public func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
    }
    
}

/**
 Standarize decimal changing commas into dots
 */
public extension String {
    public func decimal() -> String {
        return self.replacingOccurrences(of: ",", with: ".")
    }
}

