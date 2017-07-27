//
//  ShopBagEmbedVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopBagEmbedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var bakesInBag: [BakeInBagRealm]!
    var bakesPreOrder: [BakePreOrderRealm]!
    
    var avshop: AVShop!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bakesInBag = RealmHelper.retrieveBakesInBag().sorted(by: { _, _ in return true})
        bakesPreOrder = RealmHelper.retrieveBakesPreOrder().sorted(by: { _, _ in return true})
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = determineSections(avshop)
        let inBag = RealmHelper.retrieveBakesInBag().count
        let preOrder = RealmHelper.retrieveBakesPreOrder().count
        switch section {
        case 0:
            return sec % 2 == 1 ? preOrder : inBag
        case 1:
            return sec % 2 == 1 ? 0 : preOrder
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopBagEmbedTableCell") as! ShopBagEmbedTableCell
        let sec = determineSections(avshop)
        switch indexPath.section {
        case 0:
            switch sec {
            case 2, 4:
                let bake = bakesInBag[indexPath.row]
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                let price = bake.price
                if price == Double(Int(price)) {
                    cell.priceLabel.text = "¥ \(Int(price))"
                } else {
                    cell.priceLabel.text = "¥ \(String(format: "%0.2f", price))"
                }
            case 3:
                let bake = bakesPreOrder[indexPath.row]
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                let price = bake.price
                if price == Double(Int(price)) {
                    cell.priceLabel.text = "¥ \(Int(price))"
                } else {
                    cell.priceLabel.text = "¥ \(String(format: "%0.2f", price))"
                }
            default:
                break
            }
        case 1:
            switch sec {
            case 4:
                let bake = bakesPreOrder[indexPath.row]
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                let price = bake.price
                if price == Double(Int(price)) {
                    cell.priceLabel.text = "¥ \(Int(price))"
                } else {
                    cell.priceLabel.text = "¥ \(String(format: "%0.2f", price))"
                }
            default:
                break
            }
        default:
            break
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return determineSections(avshop) / 2
    }
    
    
}
