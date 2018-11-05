//
//  kintoneAPI.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class KintoneAPI {
    
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
    
    //Method GET
    func get(endpoint: String,params:JSON, callback:@escaping (JSON)->Void) {
        let queryString = self.buildQueryString(params: params)
        let url = URL(string:self.apiHost+endpoint+queryString)
        var request = URLRequest(url: url!)
        request.setValue(self.token, forHTTPHeaderField: "X-Cybozu-API-Token")
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
    
    //Method POST
    func post(endpoint: String, params:JSON, callback:@escaping (JSON)->Void) {
        let url = URL(string:self.apiHost+endpoint)
        var queryString = self.buildQueryString(params: params)
        queryString.remove(at: queryString.startIndex)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = queryString.data(using: .utf8)
        request.setValue(self.token, forHTTPHeaderField: "X-Cybozu-API-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    //Method PUT
    func put(endpoint: String, params:JSON, callback:@escaping (JSON)->Void) {
        let url = URL(string:self.apiHost+endpoint)
        var queryString = self.buildQueryString(params: params)
        queryString.remove(at: queryString.startIndex)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        do {
            request.httpBody = try params.rawData()
        } catch {
            print("Error \(error)")
        }
        request.setValue(self.token, forHTTPHeaderField: "X-Cybozu-API-Token")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
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
            print(json)
            callback(json)
        }
        task.resume()
    }
    
    init?(token: String, apiHost: String) {
        if token.isEmpty || apiHost.isEmpty {
            return nil
        }
        
        self.token = token
        self.apiHost = apiHost
    }
}
