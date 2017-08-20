//
//  OrderCheckOutVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/20/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class OrderCheckOutVC: UIViewController {

    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var checkTheOrderBtn: UIButton!
    @IBOutlet weak var backToHomeVCBtn: UIButton!
    
    var avshop: AVShop!
    var avbaker: AVBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
