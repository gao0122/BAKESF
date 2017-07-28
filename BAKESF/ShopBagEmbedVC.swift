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
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    
    let cellHeight: CGFloat = 52
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true})
        bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _, _ in return true})
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func reloadShopBagEmbedTable() {
        bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _,_ in return true })
        bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _,_ in return true })
        tableView.reloadData()
    }
    
    // MARK: - Outlet action
    @IBAction func clearAllBtnPressed(_ sender: UIButton) {
        alertOkayOrNot(okTitle: "清空", notTitle: "不", msg: "确定清空购物袋吗？", okAct: {
            _ in
            self.clearAllBakes()
        }, notAct: { _ in })
    }
    
    func clearAllBakes() {
        RealmHelper.deleteAllBakes(byShopID: avshop.objectId!)
        reloadShopBagEmbedTable()
        shopVC.setShopBagStateAndTables()
    }
    
    @IBAction func oneMoreBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBagEmbedTableCell else { return }
        if let bake = cell.bakePre {
            RealmHelper.addOneBake(bake)
            cell.amountLabel.text = "\(bake.amount)"
        }
        if let bake = cell.bakeIn {
            RealmHelper.addOneBake(bake)
            cell.amountLabel.text = "\(bake.amount)"
        }
        shopVC.setShopBagStateAndTables()
    }
    
    @IBAction func minusOneBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBagEmbedTableCell else { return }
        if let bake = cell.bakePre {
            if RealmHelper.minueOneBake(bake) {
                reloadShopBagEmbedTable()
            } else {
                cell.amountLabel.text = "\(bake.amount)"
            }
        }
        if let bake = cell.bakeIn {
            if RealmHelper.minueOneBake(bake) {
                reloadShopBagEmbedTable()
            } else {
                cell.amountLabel.text = "\(bake.amount)"
            }
        }
        shopVC.setShopBagStateAndTables()
    }
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = determineSections(avshop)
        let inBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).count
        let preOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).count
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
                cell.bakeIn = bake
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                cell.priceLabel.text = "¥ \(bake.price.fixPriceTagFormat())"
            case 3:
                let bake = bakesPreOrder[indexPath.row]
                cell.bakePre = bake
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                cell.priceLabel.text = "¥ \(bake.price.fixPriceTagFormat())"
            default:
                break
            }
        case 1:
            switch sec {
            case 4:
                let bake = bakesPreOrder[indexPath.row]
                cell.bakePre = bake
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
