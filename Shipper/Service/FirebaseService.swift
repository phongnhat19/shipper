//
//  FirebaseAPI.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/30/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftyJSON

class FirebaseService {
    var dbRef: DatabaseReference! = Database.database().reference()
    
    func saveData(data: JSON) {
        let groupKey = data["groupKey"].stringValue
        var firebaseData = [String:Any]()
        if data["data"]["status"].exists() {
            firebaseData = [
                "status":data["data"]["status"].stringValue
            ]
        }
        if data["data"]["location"].exists() {
            firebaseData["location"] = [
                "lat":data["data"]["location"]["lat"].doubleValue,
                "lng":data["data"]["location"]["lng"].doubleValue
            ]
        }
        self.dbRef.child(groupKey).child(data["data"]["orderID"].stringValue).setValue([
            "location": [
                "lat":data["data"]["location"]["lat"].doubleValue,
                "lng":data["data"]["location"]["lng"].doubleValue
            ],
            "status":data["data"]["status"].stringValue
        ])
    }
    
    init(){
        
    }
}
