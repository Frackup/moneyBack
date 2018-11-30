//
//  Lending.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 23/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class Lending: NSObject, NSCoding {
    
    //MARK: Properties
    
    var amount: Int
    var title: String
    var contact: String
    var lendingDate: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("lendings")
    
    //MARK: Types
    struct PropertyKey {
        static let amount = "amount"
        static let title = "title"
        static let contact = "contact"
        static let lendingDate = "lendingDate"
    }
    
    //MARK: Initialization
    init?(amount: Int, title: String, contact: String, lendingDate: String) {
        // The amount must not be empty nor negative
        guard amount > 0 else {
            return nil
        }
        
        // The title must not be empty
        guard !title.isEmpty else {
            return nil
        }
        
        // The contact must not be empty
        guard !contact.isEmpty else {
            return nil
        }
        
        // Initialized stored properties
        self.amount = amount
        self.title = title
        self.contact = contact
        self.lendingDate = lendingDate
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(amount, forKey: PropertyKey.amount)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(contact, forKey: PropertyKey.contact)
        aCoder.encode(lendingDate, forKey: PropertyKey.lendingDate)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The amount is required, if we cannot decode an amount, the initializer should fail
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amount)
        
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the title for a lending object", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let contact = aDecoder.decodeObject(forKey: PropertyKey.contact) as? String else {
            os_log("Unable to decode the contact for a lending object", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let lendingDate = aDecoder.decodeObject(forKey: PropertyKey.lendingDate) as? String else {
            os_log("Unable to decode the lending date for a lending object", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(amount: amount, title: title, contact: contact, lendingDate: lendingDate)
    }
}
