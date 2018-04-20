//
//  OrderCheckOutVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/20/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloudLiveQuery

class OrderCheckOutVC: UIViewController, UIGestureRecognizerDelegate, AVLiveQueryDelegate {

    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var checkTheOrderBtn: UIButton!
    @IBOutlet weak var backToHomeVCBtn: UIButton!
    
    var avshop: AVShop!
    var avbaker: AVBaker!
    var avorder: AVOrder?
    var shopVC: ShopVC!
    
    var isInBag: Bool = false
    
    var liveQuery: AVLiveQuery!
    
    let orderStatusText0 = "等待商家接单..."
    let orderStatusText1 = "商家已接单，等待配送..."
    let orderStatusText2 = "商家已配送，等待收货~"
    let orderStatusText3 = "已到达，等待确认收货"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkTheOrderBtn.setBorder(with: .bkRed)
        backToHomeVCBtn.setBorder(with: .bkRed)
        
        if let avorder = self.avorder {
            let query = AVOrder.query()
            query.includeKey("deliveryAddress")
            query.includeKey("shop")
            query.includeKey("baker")
            query.whereKey("objectId", equalTo: avorder.objectId!)
            liveQuery = AVLiveQuery(query: query)
            liveQuery.delegate = self
            liveQuery.subscribe(callback: {
                succeeded, error in
                if succeeded {
                    
                } else {
                    self.title = "下单异常，订阅失败。"
                }
            })
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(backToHomeBtnPressed(_:)))
        button.style = .plain
        navigationItem.leftBarButtonItem = button
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    @IBAction func backToHomeBtnPressed(_ sender: Any) {
        if self.navigationController?.view.layer.animation(forKey: "backToHomeFromOrder") == nil {
            let transition = CATransition()
            transition.duration = 0.32
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromBottom

            self.navigationController?.view.layer.add(transition, forKey: "backToHomeFromOrder")
        }
        guard let homeVC = self.navigationController?.viewControllers.first as? HomeVC else { return }
        self.navigationController?.popToRootViewController(animated: false)

        homeVC.searchBar.text = ""
        homeVC.cancelSearch(sender)
    }
    
    @IBAction func backToShopBtnPressed(_ sender: Any) {
        if isInBag {
            shopVC.shopBuyVC.bakeTableView.reloadData()
            shopVC.shopBuyVC.classifyTableView.reloadData()
        } else {
            shopVC.shopPreVC.bakeTableView.reloadData()
            shopVC.shopPreVC.classifyTableView.reloadData()
        }
        shopVC.setShopBagState()
        navigationController?.popToViewController(shopVC, animated: true)
    }
    
    @IBAction func checkTheOrderBtnPressed(_ sender: Any) {
        
    }
    
    
    // MARK: - LiveQuery
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
        guard let order = object as? AVOrder else {
            return
        }
        guard let status = order.status as? Int else {
            return
        }
        if updatedKeys.contains("status") {
            switch status {
            case 0:
                orderStatusLabel.text = orderStatusText0
            case 1:
                orderStatusLabel.text = orderStatusText1
            default:
                break
            }
        }
    }

}
