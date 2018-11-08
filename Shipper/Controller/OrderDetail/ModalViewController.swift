//
//  ModalViewController.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 11/8/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ModalViewController: UIViewController {
    
    var orderID: String = ""
    var token = ""
    var apiHost = ""
    private var FirebaseAPIInstance = FirebaseService()
    
    //Actions
    @IBAction func completeOrder(_ sender: Any) {
        self.updateOrderStatusToComplete(orderID: self.orderID)
        self.updateFirebaseOrderStatusToComplete(orderID: self.orderID)
        dismiss(animated: true, completion: self.backToHome)
    }
    
    @IBAction func returnOrder(_ sender: Any) {
        self.updateOrderStatusToFailed(orderID: self.orderID)
        self.updateFirebaseOrderStatusToFailed(orderID: self.orderID)
        dismiss(animated: true, completion: self.backToHome)
    }
    
    private func backToHome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let OrderListView = storyBoard.instantiateViewController(withIdentifier: "OrderList") as! OrderListController
        self.present(OrderListView, animated: true, completion: nil)
    }
    
    func updateOrderStatusToComplete(orderID: String) {
        let apiInstance = OrderAPI(token: self.token, apiHost: self.apiHost)
        
        apiInstance!.changeStatus(orderID: self.orderID, newStatus: Order.STATUS_COMPLETE) { (response) in
            
        }
    }
    
    func updateOrderStatusToFailed(orderID: String) {
        let apiInstance = OrderAPI(token: self.token, apiHost: self.apiHost)
        
        apiInstance!.changeStatus(orderID: self.orderID, newStatus: Order.STATUS_FAILED) { (response) in
            
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
    
    func updateFirebaseOrderStatusToFailed(orderID:String) {
        var firebaseData = JSON()
        firebaseData["groupKey"] = "shipperLocation"
        firebaseData["data"] = [
            "orderID":self.orderID as NSString,
            "status":Order.STATUS_FAILED as NSString
        ]
        FirebaseAPIInstance.saveData(data: firebaseData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
