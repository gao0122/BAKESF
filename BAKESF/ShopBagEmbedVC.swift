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
    
    var numOfSections: Int!
    
    let cellHeight: CGFloat = 52
    let headerHeight: CGFloat = 28
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true})
        bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _, _ in return true})
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
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
            RealmHelper.addOneMoreBake(bake)
            let amount = bake.amount
            cell.amountLabel.text = "\(amount)"
            cell.priceLabel.text = "¥ \((bake.price * Double(amount)).fixPriceTagFormat())"
        }
        if let bake = cell.bakeIn {
            let amount = bake.amount
            RealmHelper.addOneMoreBake(bake)
            cell.amountLabel.text = "\(amount)"
            cell.priceLabel.text = "¥ \((bake.price * Double(amount)).fixPriceTagFormat())"
        }
        shopVC.setShopBagStateAndTables()
    }
    
    @IBAction func minusOneBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBagEmbedTableCell else { return }
        if let bake = cell.bakePre {
            if RealmHelper.minueOneBake(bake) {
                if let indexPath = tableView.indexPath(for: cell) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .top)
                    if RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).count == 0 {
                        if tableView.numberOfSections == 2 {
                            tableView.deleteSections([1], with: .top)
                        } else {
                            tableView.deleteSections([0], with: .top)
                        }
                    }
                    tableView.endUpdates()
                } else {
                    reloadShopBagEmbedTable()
                }
            } else {
                cell.amountLabel.text = "\(bake.amount)"
            }
        }
        if let bake = cell.bakeIn {
            if RealmHelper.minueOneBake(bake) {
                if let indexPath = tableView.indexPath(for: cell) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .top)
                    if RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).count == 0 {
                        tableView.deleteSections([0], with: .top)
                    }
                    tableView.endUpdates()
                } else {
                    reloadShopBagEmbedTable()
                }
            } else {
                cell.amountLabel.text = "\(bake.amount)"
            }
        }
        shopVC.setShopBagStateAndTables()
    }
    
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return determineSections(avshop) / 2
    }
    
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
                cell.bakePre = nil
                cell.nameLabel.text = bake.name
                cell.amountLabel.text = "\(bake.amount)"
                cell.priceLabel.text = "¥ \(bake.price.fixPriceTagFormat())"
            case 3:
                let bake = bakesPreOrder[indexPath.row]
                cell.bakePre = bake
                cell.bakeIn = nil
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
                cell.bakeIn = nil
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sec = determineSections(avshop)
        switch section {
        case 0:
            return sec % 2 == 1 ? "预订" : "现货"
        case 1:
            return sec % 2 == 1 ? nil : "预订"
        default:
            return nil
        }
    }
    
    
}
