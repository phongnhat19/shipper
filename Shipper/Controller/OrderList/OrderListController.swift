//
//  OrderListController.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/25/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrderListController: UITableViewController {
    let token = "ucAgtsAdA0ZsXE0OLozQLnnFPQJrRzJ2zgA4Ab0A"
    let apiHost = "https://hbr0a.kintone.com/k/v1"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadOrders()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    var orderList = [Order]()
    var totalCount = 0
    var page = 1
    var limit = 30
    
    func updateView(ordersJSON:JSON) {
        self.totalCount = Int(ordersJSON["totalCount"].stringValue)!
        var orders = [Order]()
        for (_,recordJSON) in ordersJSON["records"] {
            let orderID = recordJSON["$id"]["value"].stringValue
            let customerName = recordJSON["customer_name"]["value"].stringValue
            let customerAddress = recordJSON["address"]["value"].stringValue
            let customerPhone = recordJSON["customer_phone"]["value"].stringValue
            let storeAddress = recordJSON["store_address"]["value"].stringValue
            let price = Int(recordJSON["store_shipping_price"]["value"].stringValue)!
            orders += [Order(orderID: orderID, customerName: customerName, customerAddress: customerAddress, customerPhone: customerPhone, storeAddress: storeAddress, price:price)!]
        }
        orderList = orders
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadOrders() {
        let apiInstance = OrderAPI(token: self.token, apiHost: self.apiHost)
        
        apiInstance!.getOrder(page: self.page, limit: self.limit, query: "", callback: updateView)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orderList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OrderCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OrderCellController else {
            fatalError("The dequeued cell is not an instance of OrderCellController.")
        }

        let order = orderList[indexPath.row]
        
        cell.customerName.text = order.customerName
        cell.customerAddress.text = order.customerAddress

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showOrderDetail" {
            
            let detailViewController = segue.destination
                as! OrderDetailController
            
            let myIndexPath = self.tableView.indexPathForSelectedRow!
            let row = myIndexPath.row
            detailViewController.orderID = orderList[row].orderID
            detailViewController.customerAddress = orderList[row].customerAddress
            detailViewController.customerPhone = orderList[row].customerPhone
            detailViewController.customerName = orderList[row].customerName
            detailViewController.storeAddress = orderList[row].storeAddress
            detailViewController.token = self.token
            detailViewController.apiHost = self.apiHost
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showOrderDetail", sender: self)
    }
}
