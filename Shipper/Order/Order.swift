//
//  Order.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit

class Order:NSObject {
    //MARK: Properties
    var orderID: String!
    var customerName: String!
    var customerAddress: String!
    var customerPhone: String!
    var storeAddress: String!
    var price: Int!
    static let STATUS_SHIPPING = "Shipping"
    static let STATUS_PENDING = "Pending"
    static let STATUS_COMPLETE = "Complete"
    static let STATUS_FAILED = "Failed"
    
    init?(orderID: String,customerName: String, customerAddress: String, customerPhone: String, storeAddress: String, price: Int) {
        
        if orderID.isEmpty || customerPhone.isEmpty || customerAddress.isEmpty || customerName.isEmpty || storeAddress.isEmpty {
            return nil
        }
        
        self.orderID = orderID
        self.customerName = customerName
        self.customerAddress = customerAddress
        self.customerPhone = customerPhone
        self.storeAddress = storeAddress
        self.price = price
    }
}
