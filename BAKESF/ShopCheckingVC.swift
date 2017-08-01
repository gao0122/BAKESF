//
//  ShopCheckingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/31/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import RealmSwift

class ShopCheckingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var segmentedControl: UISegmentedControl!
    
    let sectionCount = 3
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    
    var bakes: [Object]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = checkCurrentUser()
        
        nameLabel.text = avshop.name!
        bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        tableViewDeselection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if checkCurrentUser() {
            self.tableView.reloadData()
            retrieveBaker(withID: userRealm.id, completion: {
                object, error in
                if let baker = object as? AVBaker {
                    self.avbaker = baker
                    self.tableView.reloadData()
                } else {
                    // handle error
                }
            })
        }
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        case 1:
            bakes = RealmHelper.retrieveAllBakes(avshopID: avshop.objectId!)
        case 2:
            bakes = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        default:
            break
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // 现货或预订，配送时间，收货地址
        case 1:
            return bakes.count + 3 // 配送费，红包，总计
        case 2:
            return 3 // 支付方式，订单备注，发票
        default:
            return 0
        }
    }
    
    // Cell for Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 0:
                // segmented control
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckSegmentedControlTableCell", for: indexPath) as! ShopCheckSegmentedControlTableCell
                self.segmentedControl = cell.segmentedControl
                return cell
            case 1:
                // delivery time
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckDeliveryTimeTableCell", for: indexPath) as! ShopCheckDeliveryTimeTableCell
                return cell
            case 2:
                // delivery address
                if userRealm == nil {
                    let cell = UITableViewCell()
                    let label: UILabel = {
                        let label = UILabel()
                        label.frame = CGRect(x: (cell.frame.width - 300) / 2, y: (cell.frame.height - 24) / 2, width: 300, height: 24)
                        label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleWidth]
                        label.text = "立即登录"
                        label.textColor = .buttonBlue
                        label.textAlignment = .center
                        return label
                    }()
                    cell.addSubview(label)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckAddressTableCell", for: indexPath) as! ShopCheckAddressTableCell
                    return cell
                }
            default:
                break
            }
        case 1:
            switch row {
            case bakes.count:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                guard let fee = avshop.deliveryFee as? Double else { break }
                cell.amountLabel.alpha = 0
                cell.nameLabel.text = "配送费"
                cell.priceLabel.text = "¥ \(fee.fixPriceTagFormat())"
                return cell
            case bakes.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                cell.amountLabel.alpha = 0
                cell.nameLabel.text = "红包"
                cell.priceLabel.text = "0个可用"
                return cell
            case bakes.count + 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                let fee = RealmHelper.retrieveAllBakesCost()
                cell.nameLabel.alpha = 0
                cell.amountLabel.text = "总计"
                cell.priceLabel.text = "¥ \(fee.fixPriceTagFormat())"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                cell.amountLabel.alpha = 1
                cell.priceLabel.alpha = 1
                cell.nameLabel.alpha = 1
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    guard let bake = bakes[row] as? BakeInBagRealm else { break }
                    cell.nameLabel.text = bake.name
                    cell.amountLabel.text = "×\(bake.amount)"
                    cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                case 1:
                    if let bake = bakes[row] as? BakePreOrderRealm {
                        cell.nameLabel.text = bake.name + "（预）"
                        cell.amountLabel.text = "×\(bake.amount)"
                        cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                    } else if let bake = bakes[row] as? BakeInBagRealm {
                        cell.nameLabel.text = bake.name
                        cell.amountLabel.text = "×\(bake.amount)"
                        cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                    }
                case 2:
                    guard let bake = bakes[row] as? BakePreOrderRealm else { break }
                    cell.nameLabel.text = bake.name
                    cell.amountLabel.text = "×\(bake.amount)"
                    cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                default:
                    break
                }
                return cell
            }
        case 2:
            let cell = UITableViewCell()
            let label: UILabel = {
                let label = UILabel()
                label.frame = CGRect(x: 15, y: 9, width: 250, height: 24)
                label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleWidth]
                return label
            }()
            cell.addSubview(label)
            switch row {
            case 0:
                label.text = "支付方式"
            case 1:
                label.text = "订单备注"
            case 2:
                label.text = "发票"
            default:
                break
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    // Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 1:
                // delivery time
                break
            case 2:
                if userRealm == nil {
                    // login
                    performSegue(withIdentifier: "showLoginFromShopChecking", sender: self)
                } else {
                    // delivery address
                    
                }
                break
            default:
                break
            }
        case 1:
            switch row {
            case bakes.count + 1:
                // red packet
                break
            default:
                break
            }
        case 2:
            switch row {
            case 0:
                // pay method
                break
            case 1:
                // comments
                break
            case 2:
                // invoice
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    // Height for Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 2:
                return 72
            default:
                break
            }
        case 1:
            switch row {
            case bakes.count + 1:
                break
            case bakes.count + 2:
                break
            default:
                return 42
            }
        case 2:
            switch row {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            default:
                break
            }
        default:
            break
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sectionCount - 1 ? 15 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    func tableViewDeselection() {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else { return }
        switch id {
        case "showLoginFromShopChecking":
            guard let loginVC = segue.destination as? MeLoginVC else { break }
            loginVC.showSegueID = id
            //loginVC.backToMeBtn.addTarget(self, action: #selector(ShopCheckingVC.unwindToShopCheckingVC(segue:)), for: .touchUpInside)
        default:
            break
        }
    }

    @IBAction func unwindToShopCheckingVC(segue: UIStoryboardSegue) {
        
    }
    
    
    func checkCurrentUser() -> Bool {
        if let usr = RealmHelper.retrieveCurrentUser() {
            userRealm = usr
            avbaker = retrieveBaker(withID: userRealm.id)
            return true
        } else {
            userRealm = nil
            avbaker = nil
            return false
        }
    }
}

private let tableSections: [Int: String] = [
    0: ""
]
