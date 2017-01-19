//
//  SqliteAccess.swift
//  SqliteAccess
//
//  Created by Aldo Dell on 16/10/16.
//  Copyright © 2016 Aldo Dell. All rights reserved.
//

import Foundation

public enum SqliteType : String {
    case TEXT = "TEXT"
    case INTEGER = "INTEGER"
    case REAL = "REAL"
    case BLOB = "BLOB"
    
}

public enum SqliteAccessRowStatus {
    case NORMAL
    case INSERTED
    case UPDATED
    case DELETED
}

public func documentPath(addFile: String) -> String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/\(addFile)"
    
}




/**
 Console class for prints messages
 */
public class Console {
    public enum MESSAGE_LEVEL : Int32
    {
        case NOTHING = 0
        case ERROR = 1
        case WARNING = 2
        case INFO = 4
        case ALL = 8
    }
    
    public var level : MESSAGE_LEVEL = .ERROR
    
    public func log (message : String, level messageLevel: MESSAGE_LEVEL = .INFO) {
        if messageLevel.rawValue >= self.level.rawValue {
            print(message)
        }
    }
}


public class MessageBox  {
    
    public enum ResultButtons  {
        case Ok
        case Cancel
        case Yes
        case No
        
    }
    
    public var viewController : UIViewController
    public var result : ResultButtons?
    public var handler : ((ResultButtons)->Void)?
    
    public init(_ vc : UIViewController)
    {
        self.viewController = vc
    }
    
    @discardableResult
    public func show (_ title: String, _ message : String, _ resultButtons: ResultButtons... ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var ok  = UIAlertAction()
        var yes = UIAlertAction()
        var cancel = UIAlertAction()
        var no = UIAlertAction()
        
        
        let languageCode =  Locale.current.languageCode!
        
        switch languageCode {
            
        case "es":
            
            ok = UIAlertAction(title: "Ok", style: .default, handler: {obj in if self.handler != nil {self.handler!(.Ok)}})
            no = UIAlertAction(title: "No", style: .destructive, handler: {obj in if self.handler != nil {self.handler!(.No)}})
            yes = UIAlertAction(title: "Sí", style: .default, handler: {obj in if self.handler != nil {self.handler!(.Yes)}})
            cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: {obj in if self.handler != nil {self.handler!(.Cancel)}})
            
            
        default:
            ok = UIAlertAction(title: "Ok", style: .default, handler: {obj in if self.handler != nil {self.handler!(.Ok)}})
            no = UIAlertAction(title: "No", style: .destructive, handler: {obj in if self.handler != nil {self.handler!(.No)}})
            yes = UIAlertAction(title: "Yes", style: .default, handler: {obj in if self.handler != nil {self.handler!(.Yes)}})
            cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {obj in if self.handler != nil {self.handler!(.Cancel)}})
            
        }
        
        
        
        
        for r in resultButtons {
            
            switch r {
            case .Ok:
                alert.addAction(ok)
            case .Cancel:
                alert.addAction(cancel)
            case .Yes:
                alert.addAction(yes)
            case .No:
                alert.addAction(no)
            }
            
        }
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    @discardableResult
    public func show(_ title: String, _ message: String, actions : UIAlertAction... ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
}




