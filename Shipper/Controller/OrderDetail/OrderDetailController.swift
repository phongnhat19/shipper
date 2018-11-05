//
//  OrderDetailController.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import CoreLocation

class OrderDetailController: UIViewController, CLLocationManagerDelegate {

    //Outlets
    
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var customerAddressLabel: UILabel!
    @IBOutlet weak var customerPhoneLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var locationView: GMSMapView!
    @IBOutlet weak var startShippingButton: UIButton!
    @IBOutlet weak var startShippingRealButton: UIButton!
    
    //Actions
    @IBAction func startShipping(_ sender: Any) {
        MapAPIInstance.getLocationListOfRoute(origin: self.storeAddress, destination: self.customerAddress, callback: getRouteHandler)
    }
    @IBAction func startShippingReal(_ sender: Any) {
        DispatchQueue.main.async {
            self.locationView.isHidden = false
            self.startShippingRealButton.setTitle("Shipping...",for: .normal)
            self.startShippingButton.isEnabled = false
            self.startShippingRealButton.isEnabled = false
            self.getLocationOfShippingAddress(address: self.customerAddress,callback: self.determineMyCurrentLocation)
        }
    }
    
    //Properties
    
    var orderID: String!
    var customerAddress: String!
    var customerPhone: String!
    var customerName: String!
    var storeAddress: String!
    let ZOOM_LEVEL = 16.0
    var locationList = [JSON]()
    var locationIndex = 0
    weak var sendLocationTimer: Timer?
    var locationManager = CLLocationManager()
    var token = ""
    var apiHost = ""
    var customerLocation = CLLocation()
    let acceptableDistance = 10
    
    private var MapAPIInstance = MapService(apiKey: "AIzaSyBnUFGbu9xqETENEGAKwVTVvx2Jd61lfi0")
    private var FirebaseAPIInstance = FirebaseService()
    
    func parseListLocation(responseLocation:JSON) {
        for location in responseLocation.arrayValue {
            var locationJSON = JSON()
            locationJSON["lat"].double = location["start_location"]["lat"].doubleValue
            locationJSON["lng"].double = location["start_location"]["lng"].doubleValue
            self.locationList.append(locationJSON)
        }
        var destinationJSON = JSON()
        destinationJSON["lat"] = responseLocation.arrayValue[responseLocation.arrayValue.count-1]["end_location"]["lat"]
        destinationJSON["lng"] = responseLocation.arrayValue[responseLocation.arrayValue.count-1]["end_location"]["lng"]
        self.locationList.append(destinationJSON)
    }
    
    func getRouteHandler(responseLocation:JSON) {
        self.parseListLocation(responseLocation: responseLocation)
        DispatchQueue.main.async {
            self.locationView.isHidden = false
            self.startShippingButton.setTitle("Shipping...",for: .normal)
            self.startShippingButton.isEnabled = false
            self.startShippingRealButton.isEnabled = false
            self.sendLocationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.syncLocationToFirebase(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func updateOrderStatusToComplete(orderID: String) {
        let apiInstance = OrderAPI(token: self.token, apiHost: self.apiHost)
        
        apiInstance!.changeStatus(orderID: self.orderID, newStatus: Order.STATUS_COMPLETE) { (response) in
            
        }
    }
    
    func updateFirebaseOrderStatusToComplete(orderID:String) {
        var firebaseData = JSON()
        firebaseData["groupKey"] = "shipperLocation"
        firebaseData["data"] = [
            "orderID":self.orderID as NSString,
            "status":Order.STATUS_COMPLETE as NSString
        ]
        FirebaseAPIInstance.saveData(data: firebaseData)
    }
    
    func stopTimer(finished: Bool) {
        if (self.sendLocationTimer !== nil) {
            self.sendLocationTimer!.invalidate()
        }
        
        DispatchQueue.main.async {
            self.startShippingButton.setTitle("Ship (Fake)",for: .normal)
            self.startShippingRealButton.setTitle("Ship (Real)",for: .normal)
            self.startShippingButton.isEnabled = true
            self.startShippingRealButton.isEnabled = true
            if finished {
                self.updateOrderStatusToComplete(orderID: self.orderID)
                self.updateFirebaseOrderStatusToComplete(orderID: self.orderID)
                let alert = UIAlertController(title: "Congratulation !!!", message: "You've arrived at the customer location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "No Permission !!!", message: "Sorry, we can't get your location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func syncRealLocationToFirebase(locationJSON:JSON){
        self.renderMap(coorJSON: locationJSON)
        var firebaseData = JSON()
        firebaseData["groupKey"] = "shipperLocation"
        firebaseData["data"] = [
            "orderID":self.orderID as NSString,
            "location":[
                "lat":(locationJSON["lat"].doubleValue as NSNumber),
                "lng":(locationJSON["lng"].doubleValue as NSNumber)
            ],
            "status":Order.STATUS_SHIPPING as NSString
        ]
        FirebaseAPIInstance.saveData(data: firebaseData)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        var locationJSON = JSON()
        locationJSON["lat"].double = userLocation.coordinate.latitude
        locationJSON["lng"].double = userLocation.coordinate.longitude
        self.syncRealLocationToFirebase(locationJSON:locationJSON)
        let distanceToDestination = userLocation.distance(from: self.customerLocation)
        if distanceToDestination <= Double(self.acceptableDistance) {
            manager.stopUpdatingLocation()
            self.stopTimer(finished: true)
        }
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        manager.stopUpdatingLocation()
        print("Error \(error)")
        self.stopTimer(finished: false)
    }
    
    func listenForLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
        else {
            self.stopTimer(finished: false)
        }
    }
    
    func getLocationOfShippingAddress(address:String, callback:@escaping (JSON)->Void){
        MapAPIInstance.getLatLngFromAddress(address: address, callback: callback)
    }
    
    func determineMyCurrentLocation(location: JSON) {
        self.customerLocation = CLLocation(latitude: location["lat"].doubleValue, longitude: location["lng"].doubleValue)
        self.listenForLocation()
    }
    
    @objc func syncLocationToFirebase(_ timer: Timer){
        if self.locationIndex > self.locationList.count-1 {
            self.stopTimer(finished: true)
            return
        }
        let locationJSON = self.locationList[self.locationIndex]
        self.locationIndex += 1
        self.renderMap(coorJSON: locationJSON)
        var firebaseData = JSON()
        firebaseData["groupKey"] = "shipperLocation"
        firebaseData["data"] = [
            "orderID":self.orderID as NSString,
            "location":[
                "lat":(locationJSON["lat"].doubleValue as NSNumber),
                "lng":(locationJSON["lng"].doubleValue as NSNumber)
            ],
            "status":Order.STATUS_SHIPPING as NSString
        ]
        FirebaseAPIInstance.saveData(data: firebaseData)
    }
    
    func renderMap(coorJSON:JSON) {
        self.locationView.clear()
        let position = CLLocationCoordinate2D(latitude: coorJSON["lat"].doubleValue, longitude: coorJSON["lng"].doubleValue)
        let marker = GMSMarker(position: position)
        marker.title = "Shipper"
        marker.map = self.locationView
        self.locationView.camera = self.MapAPIInstance.loadGoogleMapCamera(centerLat: coorJSON["lat"].doubleValue, centerLng: coorJSON["lng"].doubleValue, zoom: Float(self.ZOOM_LEVEL))
    }
    
    func initMap(coorJSON:JSON) {
        let camera = GMSCameraPosition.camera(withLatitude: coorJSON["lat"].doubleValue,
                                              longitude: coorJSON["lng"].doubleValue,
                                              zoom: Float(self.ZOOM_LEVEL))
        DispatchQueue.main.sync {
            let mapView = GMSMapView.map(withFrame: self.locationView.bounds, camera: camera)
            mapView.mapType = .normal
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationView.isHidden = true
        self.MapAPIInstance.getLatLngFromAddress(address: self.storeAddress, callback: initMap)
        orderIDLabel.text = self.orderID
        customerAddressLabel.text = self.customerAddress
        customerPhoneLabel.text = self.customerPhone
        customerNameLabel.text = self.customerName
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderDetailController: GMSMapViewDelegate{
    
}
