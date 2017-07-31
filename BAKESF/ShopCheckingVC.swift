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
    
    var bakes: [Object]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = avshop.name!
        bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        
    }

    @IBAction func segmentedControlChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        } else {
            bakes = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckSegmentedControlTableCell", for: indexPath) as! ShopCheckSegmentedControlTableCell
                self.segmentedControl = cell.segmentedControl
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckDeliveryTimeTableCell", for: indexPath) as! ShopCheckDeliveryTimeTableCell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckAddressTableCell", for: indexPath) as! ShopCheckAddressTableCell
                cell.frame.size.height = 72
                return cell
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
                guard let fee = avshop.deliveryFee as? Double else { break }
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
                cell.frame.size.height = 51
                if segmentedControl.selectedSegmentIndex == 0 {
                    guard let bake = bakes[row] as? BakeInBagRealm else { break }
                    cell.nameLabel.text = bake.name
                    cell.amountLabel.text = "×\(bake.amount)"
                    cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                } else if segmentedControl.selectedSegmentIndex == 1 {
                    guard let bake = bakes[row] as? BakePreOrderRealm else { break }
                    cell.nameLabel.text = bake.name
                    cell.amountLabel.text = "×\(bake.amount)"
                    cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
                }
                return cell
            }
        case 2:
            let cell = UITableViewCell()
            let label: UILabel = {
                let label = UILabel()
                label.frame = CGRect(x: 15, y: 9, width: 300, height: 24)
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
    }

    
}

private let tableSections: [Int: String] = [
    0: ""
]
