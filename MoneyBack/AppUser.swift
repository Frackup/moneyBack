//
//  AppUser.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 28/11/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit
import os.log

class AppUser: NSObject, NSCoding {
    //MARK: Properties
    var totalAmount: Int
    var paypalConnected: Bool
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("appUser")
    
    //MARK: Types
    struct PropertyKey {
        static let totalAmount = "totalAmount"
        static let paypalConnected = "paypalConnected"
    }
    
    //MARK: Initialization
    init?(totalAmount: Int, paypalConnected: Bool) {
        guard totalAmount >= 0 else {
            return nil
        }
        
        guard paypalConnected == true || paypalConnected == false else {
            return nil
        }
        
        // Initialized stored properties
        self.totalAmount = totalAmount
        self.paypalConnected = paypalConnected
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(totalAmount, forKey: PropertyKey.totalAmount)
        aCoder.encode(paypalConnected, forKey: PropertyKey.paypalConnected)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The amount is required, if we cannot decode an amount, the initializer should fail
        let totalAmount = aDecoder.decodeInteger(forKey: PropertyKey.totalAmount)
        
        let paypalConnected = aDecoder.decodeBool(forKey: PropertyKey.paypalConnected)
        
        self.init(totalAmount: totalAmount, paypalConnected: paypalConnected)
    }
}
