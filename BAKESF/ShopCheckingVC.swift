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
    let deliveryAddressVC: DeliveryAddressVC = {
        return DeliveryAddressVC.instantiateFromStoryboard()
    }()
    
    let sectionCount = 3
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    var address: AVAddress!
    
    var bakes: [Object]!
    var deliveryTimeViewState: DeliveryTimeViewState = .collapsed
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = checkCurrentUser()
        
        deliveryTimeView.frame.origin.y = view.frame.height
        nameLabel.text = avshop.name!
        bakes = RealmHelper.retrieveAllBakes(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        
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
        case "showDeliveryAddressFromShopCheckingVC":
            guard let daVC = segue.destination as? DeliveryAddressVC else { break }
            daVC.avbaker = self.avbaker
            daVC.shopCheckingVC = self
            show(daVC, sender: self)
        default:
            break
        }
    }
    
    @IBAction func unwindToShopCheckingVC(segue: UIStoryboardSegue) {
        
    }
    

    @IBAction func checkOutBtnPressed(_ sender: Any) {
        
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
                // 现货或预订，配送时间，收货地址
                let sections = determineSections(avshop)
                if segmentedControl == nil { return 3 }
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    switch sections {
                    case 2, 4:
                        return 3
                    case 3:
                        return 1
                    default:
                        break
                    }
                case 1:
                    switch sections {
                    case 2, 3:
                        return 3
                    case 4:
                        return 5
                    default:
                        break
                    }
                case 2:
                    switch sections {
                    case 2:
                        return 1
                    case 3, 4:
                        return 3
                    default:
                        break
                    }
                default:
                    break
                }
            case 1:
                let sections = determineSections(avshop)
                if segmentedControl == nil { return bakes.count + 3 }
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    switch sections {
                    case 3:
                        return 1
                    default:
                        break
                    }
                case 1:
                    switch sections {
                    case 4:
                        return bakes.count + 4
                    default:
                        break
                    }
                case 2:
                    switch sections {
                    case 2:
                        return 1
                    default:
                        break
                    }
                default:
                    break
                }
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckSegmentedControlTableViewCell", for: indexPath) as! ShopCheckSegmentedControlTableViewCell
                    self.segmentedControl = cell.segmentedControl
                    return cell
                case 1:
                    // delivery time
                    return deliveryTimeCell(indexPath)
                case 2:
                    // delivery address
                    if userRealm == nil {
                        return centerTextCell("立即登录", color: .buttonBlue)
                    } else {
                        return deliveryAddressCell(indexPath)
                    }
                case 3:
                    let sections = determineSections(avshop)
                    switch segmentedControl.selectedSegmentIndex {
                    case 1:
                        switch sections {
                        case 4:
                            if userRealm != nil {
                                // delivery time
                                return deliveryTimeCell(indexPath, preOrder: true)
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                case 4:
                    let sections = determineSections(avshop)
                    switch segmentedControl.selectedSegmentIndex {
                    case 1:
                        switch sections {
                        case 4:
                            if userRealm != nil {
                                // delivery address
                                return deliveryAddressCell(indexPath, preOrder: true)
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                default:
                    break
                }
            case 1:
                let sections = determineSections(avshop)
                let sc = segmentedControl.selectedSegmentIndex
                switch row {
                case bakes.count:
                    if tableView.numberOfRows(inSection: section) == 1 {
                        let cell = centerTextCell("袋子空空的", color: .bkBlack)
                        cell.selectionStyle = .none
                        return cell
                    } else {
                        return deliveryFeeCell(indexPath)
                    }
                case bakes.count + 1:
                    if sections == 4 && sc == 1 {
                        return deliveryFeeCell(indexPath, preOrder: true)
                    } else {
                        return redPacketCell(indexPath)
                    }
                case bakes.count + 2:
                    if sections == 4 && sc == 1 {
                        return redPacketCell(indexPath)
                    } else {
                        return totalFeeCell(indexPath)
                    }
                case bakes.count + 3:
                    return totalFeeCell(indexPath)
                default:
                    return bakeItemCell(indexPath)
                }
            case 2:
                return otherCell(indexPath)
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
    
    // Table Cells
    private func totalFeeCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        // TODO: Delivery fee part
        guard var fee = avshop.deliveryFee as? Double else { return cell }
        let sections = determineSections(avshop)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            fee += RealmHelper.retrieveBakesInBagCost(avshopID: avshop.objectId!)
        case 1:
            if sections == 4 { fee += fee } // TODO: in bag fee plus pre order fee
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
    }
    
    private func redPacketCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        cell.priceLabel.alpha = 1
        cell.nameLabel.alpha = 1
        cell.amountLabel.alpha = 0
        cell.nameLabel.text = "红包"
        cell.priceLabel.text = "0个可用"
        return cell
    }
    
    private func deliveryFeeCell(_ indexPath: IndexPath, preOrder: Bool = false) -> ShopCheckBakeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        guard let fee = avshop.deliveryFee as? Double else { return cell }
        cell.priceLabel.alpha = 1
        cell.nameLabel.alpha = 1
        cell.amountLabel.alpha = 0
        cell.nameLabel.text = "配送费" + (preOrder ? "（预）" : "")
        cell.priceLabel.text = "¥ \(fee.fixPriceTagFormat())"
        return cell
    }
    
    private func bakeItemCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
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
    
    private func otherCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 15, y: 9, width: 250, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleWidth]
            return label
        }()
        cell.addSubview(label)
        switch indexPath.row {
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
    }
    
    private func centerTextCell(_ text: String, color: UIColor) -> UITableViewCell {
        let cell = UITableViewCell()
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: (cell.frame.width - 300) / 2, y: (cell.frame.height - 24) / 2, width: 300, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleWidth]
            label.text = text
            label.textColor = color
            label.textAlignment = .center
            return label
        }()
        cell.addSubview(label)
        return cell
    }
    
    private func deliveryTimeCell(_ indexPath: IndexPath, preOrder: Bool = false) -> ShopCheckDeliveryTimeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckDeliveryTimeTableViewCell", for: indexPath) as! ShopCheckDeliveryTimeTableViewCell
        if preOrder {
            if !cell.arrivalTime.text!.contains("（预）") {
                cell.arrivalTime.text = cell.arrivalTime.text! + "（预）"
            }
        }
        return cell
    }
    
    private func deliveryAddressCell(_ indexPath: IndexPath, preOrder: Bool = false) -> ShopCheckAddressTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckAddressTableViewCell", for: indexPath) as! ShopCheckAddressTableViewCell
        if address == nil {
            
        } else {
            cell.addressLabel.text = address.formatted
            cell.phoneLabel.text = address.phone
            if preOrder {
                if !cell.phoneLabel.text!.contains("（预）") {
                    cell.phoneLabel.text = cell.phoneLabel.text! + "（预）"
                }
            }
        }
        cell.nameLabel.sizeToFit()
        cell.phoneLabel.sizeToFit()
        return cell
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
                case 1, 3:
                    // delivery time
                    // TODO: - deliveryTimeSwitch(row)
                    break
                case 2, 4:
                    if userRealm == nil {
                        // login
                        performSegue(withIdentifier: "showLoginFromShopChecking", sender: self)
                    } else {
                        // delivery address
                        let segue = UIStoryboardSegue(identifier: "showDeliveryAddressFromShopCheckingVC", source: self, destination: deliveryAddressVC)
                        prepare(for: segue, sender: self)
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
    
    func deliveryTimeSwitch(_ row: Int? = nil) {
        switch deliveryTimeViewState {
        case .collapsed:
            deliveryTimeViewState = .expanded
            let bgView = UIView(frame: UIScreen.main.bounds)
            bgView.restorationIdentifier = "bgView"
            bgView.alpha = 0
            bgView.backgroundColor = UIColor(hex: 0x121212, alpha: 0.84)
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopCheckingVC.deliveryTimeSwitchSelector(_:))))
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
    
    func deliveryTimeSwitchSelector(_ sender: UITapGestureRecognizer) {
        deliveryTimeSwitch()
    }
    
    // Height for Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag > 0 { return 44 }
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 2, 4:
                return UITableViewAutomaticDimension
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 2, 4:
                return 72
            default:
                return 44
            }
        default:
            return 44
        }
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
