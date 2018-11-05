//
//  MapAPI.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/26/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class MapService {
    
    //Properties
    var GOOGLE_API_KEY = ""
    let STROKE_WIDTH = 3.0
    let DIRECTION_ROUTE = "https://maps.googleapis.com/maps/api/directions/json"
    let GEOLOCATION_ROUTE = "https://maps.googleapis.com/maps/api/geocode/json"
    
    func getLatLngFromAddress(address:String, callback:@escaping (JSON)->Void) {
        let urlString = "?address="+address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!+"&key="+self.GOOGLE_API_KEY
        let url = URL(string:self.GEOLOCATION_ROUTE+urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
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
            if json["status"].stringValue == "OK" {
                callback(json["results"][0]["geometry"]["location"])
            }
        }
        task.resume()
    }
    
    func getLocationListOfRoute(origin:String, destination:String, callback: @escaping (JSON)->Void) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "\(self.DIRECTION_ROUTE)?origin=\(origin.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&destination=\(destination.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&key=\(self.GOOGLE_API_KEY)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
            guard error == nil else {
                print("returned error")
                return
            }
            guard let content = data else {
                print("No data")
                return
            }
            let json = JSON(content)
            if json["status"].stringValue == "OK" {
                callback(json["routes"][0]["legs"][0]["steps"])
            }
        })
        task.resume()
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, mapView: GMSMapView){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "\(self.DIRECTION_ROUTE)origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        let overview_polyline = routes?[0] as?[String:Any]
                        let polyString = overview_polyline?["points"] as?String
                        
                        //Call this method to draw path on map
                        self.showPath(polyStr: polyString!, mapView: mapView)
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    func showPath(polyStr :String, mapView: GMSMapView){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = CGFloat(self.STROKE_WIDTH)
        polyline.map = mapView // Your map view
        
    }
    func loadGoogleMapCamera(centerLat: Double, centerLng: Double, zoom: Float) -> GMSCameraPosition{
        let camera = GMSCameraPosition.camera(withLatitude: centerLat, longitude: centerLng, zoom: zoom)
        return camera
    }
    init(apiKey:String){
        self.GOOGLE_API_KEY = apiKey
    }
}
