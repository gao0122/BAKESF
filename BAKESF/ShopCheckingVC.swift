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

    enum DeliveryTimeViewState {
        case collapsed, expanded
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deliveryTimeView: UIView!
    @IBOutlet weak var deliveryTimeViewCancelBtn: UIButton!
    
    
    var segmentedControl: UISegmentedControl!
    
    let sectionCount = 3
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    
    var bakes: [Object]!
    var deliveryTimeViewState: DeliveryTimeViewState = .collapsed
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = checkCurrentUser()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        deliveryTimeView.frame.origin.y = view.frame.height
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
    
    @IBAction func deliveryTimeViewCancelBtnPressed(_ sender: UIButton) {
        if deliveryTimeViewState == .expanded {
            deliveryTimeSwitch()
        }
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0:
            return sectionCount
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
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
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        return 0
    }
    
    // Cell for Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch tableView.tag {
        case 0:
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
                    cell.priceLabel.alpha = 1
                    cell.nameLabel.alpha = 1
                    cell.amountLabel.alpha = 0
                    cell.nameLabel.text = "配送费"
                    cell.priceLabel.text = "¥ \(fee.fixPriceTagFormat())"
                    return cell
                case bakes.count + 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                    cell.priceLabel.alpha = 1
                    cell.nameLabel.alpha = 1
                    cell.amountLabel.alpha = 0
                    cell.nameLabel.text = "红包"
                    cell.priceLabel.text = "0个可用"
                    return cell
                case bakes.count + 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableCell", for: indexPath) as! ShopCheckBakeTableCell
                    guard var fee = avshop.deliveryFee as? Double else { break }
                    switch segmentedControl.selectedSegmentIndex {
                    case 0:
                        fee += RealmHelper.retrieveBakesInBagCost(avshopID: avshop.objectId!)
                    case 1:
                        fee += RealmHelper.retrieveAllBakesCost(avshopID: avshop.objectId!)
                    case 2:
                        fee += RealmHelper.retrieveBakesPreOrderCost(avshopID: avshop.objectId!)
                    default:
                        break
                    }
                    cell.priceLabel.alpha = 1
                    cell.nameLabel.alpha = 0
                    cell.amountLabel.alpha = 1
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
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        return UITableViewCell()
    }
    
    // Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        switch tableView.tag {
        case 0:
            switch section {
            case 0:
                switch row {
                case 1:
                    // delivery time
                    deliveryTimeSwitch()
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
        case 1:
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func deliveryTimeSwitch(_ sender: UITapGestureRecognizer? = nil) {
        switch deliveryTimeViewState {
        case .collapsed:
            deliveryTimeViewState = .expanded
            let bgView = UIView(frame: UIScreen.main.bounds)
            bgView.restorationIdentifier = "bgView"
            bgView.alpha = 0
            bgView.backgroundColor = UIColor(hex: 0x121212, alpha: 0.84)
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopCheckingVC.deliveryTimeSwitch(_:))))
            view.addSubview(bgView)
            view.bringSubview(toFront: deliveryTimeView)
            UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.84, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                self.deliveryTimeView.frame.origin.y = self.view.frame.height - self.deliveryTimeView.frame.height
                self.deliveryTimeView.alpha = 1
                bgView.alpha = 1
            }, completion: nil)
        case .expanded:
            deliveryTimeViewState = .collapsed
            view.subviews.forEach({
                if $0.restorationIdentifier == "bgView" {
                    let bgView = $0
                    UIView.animate(withDuration: 0.48, delay: 0, usingSpringWithDamping: 0.84, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                        self.deliveryTimeView.frame.origin.y = self.view.frame.height
                        self.deliveryTimeView.alpha = 0
                        bgView.alpha = 0
                    }, completion: {
                        finished in
                        bgView.removeFromSuperview()
                    })
                }
            })
        }
    }
    
    // Height for Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag > 0 { return 44 }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag > 0 { return 0 }
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
