//
//  ViewController.swift
//  Shipper
//
//  Created by Nguyen Phong Nhat on 10/24/18.
//  Copyright © 2018 CybozuVN. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    //Properties
    let token = "KXQEk6OHQfJt0FrH8AkHGF344GREuqFqKvCJzThb"
    let apiHost = "https://nhat-nguyen.cybozu-dev.com/k/v1"
    
    //Outlets
    @IBOutlet weak var labelHello: UILabel!
    
    // Action handler
    
    @IBAction func startShipping(_ sender: Any) {
        //Navigate to OrderList Screen
        let mainSB = UIStoryboard(name:"Main",bundle:nil)
        let orderListScreen = mainSB.instantiateViewController(withIdentifier: "OrderList") as! OrderListController
        self.navigationController?.pushViewController(orderListScreen, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

