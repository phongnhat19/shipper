//
//  OrderAPI.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderAPI: Codable {
    var apiHost:String = ""
    var token:String = ""
    let appID:String = "48"
    
    init?(token: String, apiHost: String) {
        if token.isEmpty || apiHost.isEmpty {
            return nil
        }
        
        self.token = token
        self.apiHost = apiHost
    }
    
    func getOrder(page:Int, limit:Int, query:Any, callback:@escaping (JSON)->Void) {
        let kintoneAPI = KintoneAPI(token:self.token,apiHost:self.apiHost)
        var params = JSON()
        params["page"].int = page
        params["limit"].int = limit
        params["app"].string = appID
        params["query"].string = "status in (\"\(Order.STATUS_PENDING)\")"
        params["totalCount"].string = "true"
        kintoneAPI!.get(endpoint: "/records.json", params: params, callback:callback)
    }
    
    func changeStatus(orderID:String, newStatus:String, callback:@escaping (JSON)->Void) {
        let kintoneAPI = KintoneAPI(token:self.token,apiHost:self.apiHost)
        var params = JSON()
        params["app"].string = appID
        params["id"].string = orderID
        params["record"].dictionaryObject = [
            "status":[
                "value":newStatus
            ]
        ]
        kintoneAPI!.put(endpoint: "/record.json", params: params, callback:callback)
    }
    
    func getOrderDetail(orderID: String, callback:@escaping (JSON)->Void) {
        let kintoneAPI = KintoneAPI(token:self.token,apiHost:self.apiHost)
        var params = JSON()
        params["app"].string = appID
        params["id"].string = orderID
        kintoneAPI!.get(endpoint: "/record.json", params: params, callback:callback)
    }
}
