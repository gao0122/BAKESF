//
//  OrderDetailVC.swift
//  BAKESF
//
//  Created by 高宇超 on 9/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

class OrderDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var orderVC: OrderVC!
    var order: AVOrder!
    var avbakes: [AVObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navBar = navigationController?.navigationBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.frame.origin.y = screenHeight
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        orderVC.tableViewCellDeselection()
    }
    
    class func instantiateFromStoryboard(with order: AVOrder, orderVC: OrderVC) -> OrderDetailVC {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! OrderDetailVC
        vc.order = order
        vc.orderVC = orderVC
        return vc
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let status = order.status?.intValue else { return 0 }
        switch status {
        case 0:
            // new order, to be paid by user
            return 0
        case 1:
            // paid, to be taken by shop
            return 0
        case 2:
            // taken, to be produced by shop
            return 0
        case 3:
            // produced, to be delivered by shop
            return 0
        case 4:
            // delivered, to arrive
            return 0
        case 5:
            // arrived, to be confirmed by user
            return 0
        case 6:
            // confirmed, to be commented by user
            return 0
        case 7:
            // commented, to be confirmed by user
            return 0
        case 8:
            // commented and confirmed, done
            return 0
        case 9:
            // canceled
            return 4
        case 10:
            // charge back
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let status = order.status?.intValue else { return 0 }
        switch status {
        case 0:
            switch section {
            case 0:
                // basic info
                return 1
            case 1:
                // delivery time or ad.
                return 1
            case 2:
                // bakes: - shop name, delivery fee, total cost
                return avbakes.count + 3
            case 3:
                // delivery info: - title, delivery time, delivery address, delivery way
                return 4
            case 4:
                // order detail: - title, order id, payment method, createdTime
                return 4
            case 5:
                break
            case 6:
                break
            default:
                break
            }
        case 1:
            return 0
        case 2:
            return 0
        case 3:
            return 0
        case 4:
            return 0
        case 5:
            return 0
        case 6:
            return 0
        case 7:
            return 0
        case 8:
            return 0
        default:
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
            return cell
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        case 6:
            break
        default:
            break
        }
        return UITableViewCell()
    }
    
    
}
