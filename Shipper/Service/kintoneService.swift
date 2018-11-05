//
//  kintoneAPI.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class KintoneService {
    
    //Properties
    var token = ""
    var apiHost = ""
    
    private func buildQueryString(params:JSON) -> String{
        var queryString:String = ""
        for (key,value):(String, JSON) in params {
            if queryString.isEmpty {
                queryString += "?" + key + "=" + value.stringValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            }
            else {
                queryString += "&" + key + "=" + value.stringValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            }
        }
        return queryString
    }
    
    //Build request
    private func buildRequestObject(endpoint: String,params:JSON, method: String) -> URLRequest {
        let queryString = self.buildQueryString(params: params)
        var urlString = self.apiHost+endpoint
        if method == "GET" {
            urlString += queryString
        }
        let url = URL(string:urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = method
        if ["POST"].contains(method) {
            request.httpBody = queryString.data(using: .utf8)
        }
        else if ["PUT"].contains(method) {
            do {
                request.httpBody = try params.rawData()
            } catch {
                print("Error \(error)")
            }
        }
        request.setValue(self.token, forHTTPHeaderField: "X-Cybozu-API-Token")
        
        if ["POST","PUT"].contains(method) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    private func sendRequest(request: URLRequest,callback:@escaping (JSON)->Void) {
        let task = URLSession.shared.dataTask(with: request) {(data, response, error ) in
            guard error == nil else {
                print("returned error")
                return
            }
            guard let content = data else {
                print("No data")
                return
            }
            let json = JSON(content)
            callback(json)
        }
        task.resume()
    }
    
    //Method GET
    func get(endpoint: String,params:JSON, callback:@escaping (JSON)->Void) {
        let request = self.buildRequestObject(endpoint: endpoint, params: params, method: "GET")
        self.sendRequest(request: request, callback: callback)
    }
    
    //Method POST
    func post(endpoint: String, params:JSON, callback:@escaping (JSON)->Void) {
        let request = self.buildRequestObject(endpoint: endpoint, params: params, method: "POST")
        self.sendRequest(request: request, callback: callback)
    }
    
    //Method PUT
    func put(endpoint: String, params:JSON, callback:@escaping (JSON)->Void) {
        let request = self.buildRequestObject(endpoint: endpoint, params: params, method: "PUT")
        self.sendRequest(request: request, callback: callback)
    }
    
    init?(token: String, apiHost: String) {
        if token.isEmpty || apiHost.isEmpty {
            return nil
        }
        
        self.token = token
        self.apiHost = apiHost
    }
}
