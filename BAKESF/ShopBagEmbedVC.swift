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
        if shopVC.pagingMenuController.currentPage == 0 {
            bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _,_ in return true })
        } else {
            bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _,_ in return true })
        }
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
        if shopVC.pagingMenuController.currentPage == 0 {
            RealmHelper.deleteAllBakesInBag(by: avshop.objectId!)
        } else {
            RealmHelper.deleteAllBakesPreOrder(by: avshop.objectId!)
        }
        reloadShopBagEmbedTable()
        shopVC.setShopBagStateAndTables()
    }
    
    @IBAction func oneMoreBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBagEmbedTableCell else { return }
        if let bake = cell.bakePre {
            RealmHelper.addOneMoreBake(bake)
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
        }
        if let bake = cell.bakeIn {
            RealmHelper.addOneMoreBake(bake)
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
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
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
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
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
            }
        }
        shopVC.setShopBagStateAndTables()
    }
    
    func setCellAmountPriceLabel(for cell: ShopBagEmbedTableCell, with amount: Int, price: Double, name: String) {
        cell.nameLabel.text = name
        cell.amountLabel.text = "\(amount)"
        cell.priceLabel.text = "¥ \((price * Double(amount)).fixPriceTagFormat())"
    }
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shopVC.pagingMenuController == nil { return 0 }
        if shopVC.pagingMenuController.currentPage == 0 {
            return RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).count
        } else {
            return RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopBagEmbedTableCell") as! ShopBagEmbedTableCell
        if shopVC.pagingMenuController.currentPage == 0 {
            let bake = bakesInBag[indexPath.row]
            cell.bakeIn = bake
            cell.bakePre = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
        } else {
            let bake = bakesPreOrder[indexPath.row]
            cell.bakePre = bake
            cell.bakeIn = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
        }
        return cell
    }
    
    
}
