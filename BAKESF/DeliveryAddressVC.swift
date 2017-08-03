//
//  DeliveryAddressVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/1/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressVC: UIViewController {

    let tableView: UITableView = {
        let tv = UITableView()
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        view.addSubview(tableView)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
