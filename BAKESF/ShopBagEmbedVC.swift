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
    
    var bakesInBag: [BakeInBagRealm]?
    var bakesPreOrder: [BakePreOrderRealm]?
    var avbakesIn: [AVBakeIn]?
    var avbakesPre: [AVBakePre]?
    
    var shopVC: ShopVC!
    var avshop: AVShop!
        
    let cellHeight: CGFloat = 52
    let headerHeight: CGFloat = 28
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func reloadShopBagEmbedTable() {
        if shopVC.pagingMenuController == nil { return }
        reloadBakes()
        tableView.reloadData()
    }
    
    func reloadBakes() {
        // TODO: - change 'bakee' to 'bake' after finished bake specification
        if shopVC.pagingMenuController.currentPage == 0 {
            avbakesIn = shopVC.shopBuyVC.avbakesIn.values.sorted(by: { b1, b2 in return b1.bakee!.objectId! < b2.bakee!.objectId! })
            bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { b1, b2 in return b1.id < b2.id })
        } else {
            avbakesPre = shopVC.shopPreVC.avbakesPre.values.sorted(by: { b1, b2 in return b1.bakee!.objectId! < b2.bakee!.objectId! })
            bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { b1, b2 in return b1.id < b2.id })
        }
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
            shopVC.shopBuyVC.avbakesIn.removeAll()
            RealmHelper.deleteAllBakesInBag(by: avshop.objectId!)
        } else {
            shopVC.shopPreVC.avbakesPre.removeAll()
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
            shopVC.shopPreVC.assignAVBakeOrder(bakeRealm: bake, bake: cell.bake!)
        }
        if let bake = cell.bakeIn {
            RealmHelper.addOneMoreBake(bake)
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
            shopVC.shopBuyVC.assignAVBakeOrder(bakeRealm: bake, bake: cell.bake!)
        }
        shopVC.setShopBagStateAndTables()
    }
    
    @IBAction func minusOneBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBagEmbedTableCell else { return }
        if let bake = cell.bakePre {
            let id = bake.id
            if RealmHelper.minueOneBake(bake) {
                shopVC.shopBuyVC.avbakesIn[id] = nil
                printit(shopVC.shopPreVC.avbakesPre)
                if let indexPath = tableView.indexPath(for: cell) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .top)
                    shopVC.shopPreVC.avbakesPre[id] = nil
                    reloadBakes()
                    tableView.endUpdates()
                } else {
                    shopVC.shopBuyVC.avbakesIn[id] = nil
                    reloadShopBagEmbedTable()
                }
            } else {
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
                shopVC.shopPreVC.assignAVBakeOrder(bakeRealm: bake, bake: cell.bake!)
            }
        }
        if let bake = cell.bakeIn {
            let id = bake.id
            if RealmHelper.minueOneBake(bake) {
                shopVC.shopBuyVC.avbakesIn[id] = nil
                printit(shopVC.shopBuyVC.avbakesIn)
                if let indexPath = tableView.indexPath(for: cell) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .top)
                    reloadBakes()
                    tableView.endUpdates()
                } else {
                    reloadShopBagEmbedTable()
                }
            } else {
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
                shopVC.shopBuyVC.assignAVBakeOrder(bakeRealm: bake, bake: cell.bake!)
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
            return bakesInBag?.count ?? 0
        } else {
            return bakesPreOrder?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopBagEmbedTableCell") as! ShopBagEmbedTableCell
        let row = indexPath.row
        if shopVC.pagingMenuController.currentPage == 0 {
            guard let bake = bakesInBag?[row] else { return cell }
            cell.bake = avbakesIn![row].bakee
            cell.bakeIn = bake
            cell.bakePre = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
        } else {
            guard let bake = bakesPreOrder?[indexPath.row] else { return cell }
            cell.bake = avbakesPre![row].bakee
            cell.bakePre = bake
            cell.bakeIn = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
        }
        return cell
    }
    
    
}
