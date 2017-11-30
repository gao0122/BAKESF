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
            avbakesIn = shopVC.shopBuyVC.avbakesIn.values.sorted(by: { b1, b2 in return b1.bake!.objectId! < b2.bake!.objectId! })
            bakesInBag = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!, avbakesIn: shopVC.shopBuyVC.avbakesIn).sorted(by: { b1, b2 in return b1.id < b2.id })
        } else {
            avbakesPre = shopVC.shopPreVC.avbakesPre.values.sorted(by: { b1, b2 in return b1.bake!.objectId! < b2.bake!.objectId! })
            bakesPreOrder = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!, avbakesPre: shopVC.shopPreVC.avbakesPre).sorted(by: { b1, b2 in return b1.id < b2.id })
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
        guard let bakeDetail = cell.bakeDetail else { return }
        if let bake = cell.bakePre {
            RealmHelper.addOneMoreBake(bake)
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
            shopVC.shopPreVC.assignAVBakeOrder(bakeRealm: bake, bake: bakeDetail)
        }
        if let bake = cell.bakeIn {
            RealmHelper.addOneMoreBake(bake)
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
            shopVC.shopBuyVC.assignAVBakeOrder(bakeRealm: bake, bake: bakeDetail)
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
            } else if let bakeDetail = cell.bakeDetail {
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
                shopVC.shopPreVC.assignAVBakeOrder(bakeRealm: bake, bake: bakeDetail)
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
            } else if let bakeDetail = cell.bakeDetail {
                setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name)
                shopVC.shopBuyVC.assignAVBakeOrder(bakeRealm: bake, bake: bakeDetail)
            }
        }
        shopVC.setShopBagStateAndTables()
    }
    
    func setCellAmountPriceLabel(for cell: ShopBagEmbedTableCell, with amount: Int, price: Double, name: String, bakeDetail: AVBakeDetail? = nil) {
        var bakeName = name
        if let bake = bakeDetail?.bake {
            if let attrs = bake.attributes {
                switch attrs.count {
                case 1:
                    if let attr0 = bakeDetail?.attributes?.attribute0 {
                        bakeName += "（\(attr0.key ?? ""):\(attr0.value ?? "")）"
                    }
                case 2:
                    if let attr0 = bakeDetail?.attributes?.attribute0 {
                        bakeName += "（\(attr0.key ?? ""):\(attr0.value ?? ""),"
                    }
                    if let attr1 = bakeDetail?.attributes?.attribute1 {
                        bakeName += " \(attr1.key ?? ""):\(attr1.value ?? "")）"
                    }
                case 3:
                    if let attr0 = bakeDetail?.attributes?.attribute0 {
                        bakeName += "（\(attr0.key ?? ""):\(attr0.value ?? ""),"
                    }
                    if let attr1 = bakeDetail?.attributes?.attribute1 {
                        bakeName += " \(attr1.key ?? ""):\(attr1.value ?? ""),"
                    }
                    if let attr2 = bakeDetail?.attributes?.attribute2 {
                        bakeName += " \(attr2.key ?? ""):\(attr2.value ?? "")）"
                    }
                default:
                    break
                }
            }
        }
        cell.nameLabel.text = bakeName
        cell.amountLabel.text = "\(amount)"
        cell.priceLabel.text = "¥ \((price * Double(amount)).fixPriceTagFormat())"
        
        let originPriceLabelWidth = cell.priceLabel.frame.width
        let originPriceLabelX = cell.priceLabel.frame.origin.x
        cell.priceLabel.sizeToFit()
        cell.priceLabel.frame.origin.x += originPriceLabelWidth - cell.priceLabel.frame.width
        cell.nameLabelWidth.constant = originPriceLabelX - cell.nameLabel.frame.origin.x - 10
    }
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shopVC.pagingMenuController == nil { return 0 }
        if shopVC.pagingMenuController.currentPage == 0 {
            return avbakesIn?.count ?? 0
        } else {
            return avbakesPre?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopBagEmbedTableCell") as! ShopBagEmbedTableCell
        let row = indexPath.row
        if shopVC.pagingMenuController.currentPage == 0 {
            guard let bake = bakesInBag?[row] else { return cell }
            guard let bakeDetail = avbakesIn![row].bake else { return cell }
            cell.bakeDetail = bakeDetail
            cell.bakeIn = bake
            cell.bakePre = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name, bakeDetail: bakeDetail)
        } else {
            guard let bake = bakesPreOrder?[indexPath.row] else { return cell }
            guard let bakeDetail = avbakesPre![row].bake else { return cell }
            cell.bakeDetail = bakeDetail
            cell.bakePre = bake
            cell.bakeIn = nil
            setCellAmountPriceLabel(for: cell, with: bake.amount, price: bake.price, name: bake.name, bakeDetail: bakeDetail)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
