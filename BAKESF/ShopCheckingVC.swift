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
    @IBOutlet weak var deliveryTimeView: UIView!
    @IBOutlet weak var deliveryTimeViewCancelBtn: UIButton!
    @IBOutlet weak var deliveryTimeDateTableView: UITableView!
    @IBOutlet weak var deliveryTimeTableView: UITableView!
    @IBOutlet weak var checkoutBtn: UIButton!
    
    var segmentedControl: UISegmentedControl!
    var segmentedControlDeliveryWay: UISegmentedControl!
    let deliveryAddressVC: DeliveryAddressVC = {
        return DeliveryAddressVC.instantiateFromStoryboard()
    }()
    var redPacketVC: RedPacketVC!
    
    let sectionCount = 3
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    var avaddress: AVAddress?
    var avaddressPreOrder: AVAddress?
    var avorder: AVOrder?
    
    var bakes: [Object]!
    var deliveryTimeViewState: DeliveryTimeViewState = .collapsed
    var deliveryDatecs = [DateComponents]()
    var deliveryDates = [String]()
    var deliveryTimecs = [DateComponents]()
    var deliveryTimes = [String]()
    var selectedTimeIn: DateComponents?
    var selectedTime: DateComponents?
    
    let checkoutBtnText = "支付全部"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = checkCurrentUser()
        
        self.title = avshop.name!
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        checkoutBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        checkoutBtn.titleLabel?.minimumScaleFactor = 0.5

        deliveryTimeView.frame.origin.y = view.frame.height
        bakes = RealmHelper.retrieveAllBakes(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.tableFooterView = footerView
        deliveryTimeDateTableView.tableFooterView = footerView
        deliveryTimeTableView.tableFooterView = footerView
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.isUserInteractionEnabled = true
        tableViewDeselection()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if checkCurrentUser() {
            retrieveBaker(withID: userRealm.id, completion: {
                object, error in
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                if let baker = object as? AVBaker {
                    self.avbaker = baker
                    retrieveRecentlyAddress(by: baker, completion: {
                        objects, error in
                        if let error = error {
                            self.avaddress = nil
                            self.avaddressPreOrder = nil
                            self.setCheckOutBtn(enabled: false)
                            printit("Retrieve address error: \(error.localizedDescription)")
                        } else {
                            if let addresses = objects as? [AVAddress] {
                                self.avaddressPreOrder = nil
                                self.avaddress = nil
                                for address in addresses {
                                    if address.isForPreOrder {
                                        self.avaddressPreOrder = address
                                    }
                                    if address.isForRightNow {
                                        self.avaddress = address
                                    }
                                }
                                self.setCheckOutBtn(enabled: true)
                            } else {
                                self.avaddress = nil
                                self.avaddressPreOrder = nil
                                self.setCheckOutBtn(enabled: false)
                            }
                        }
                        self.tableView.reloadData()
                    })
                } else {
                    // TODO: - handle error
                    self.setCheckOutBtn(enabled: false)
                }
            })
        } else {
            self.setCheckOutBtn(enabled: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func setCheckOutBtn(enabled: Bool) {
        let secs = determineSections(avshop)
        let enabled = !(secs > 2 && selectedTime == nil) && enabled
        self.checkoutBtn.isEnabled = enabled
        UIView.animate(withDuration: 0.27, animations: {
            self.checkoutBtn.backgroundColor = enabled ? .appleGreen : .checkBtnGray
        }, completion: {
            finished in
            self.checkoutBtn.backgroundColor = enabled ? .appleGreen : .checkBtnGray
        })
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setBackItemTitle(for: navigationItem)
        guard let id = segue.identifier else { return }
        switch id {
        case "showLoginFromShopChecking":
            guard let loginVC = segue.destination as? MeLoginVC else { break }
            loginVC.showSegueID = id
        case "showDeliveryAddressFromShopCheckingVC":
            guard let daVC = segue.destination as? DeliveryAddressVC else { break }
            daVC.avbaker = self.avbaker
            daVC.shopCheckingVC = self
            daVC.currentAddress = self.avaddress
            show(daVC, sender: self)
        case "showRedPacketVCFromShopCheckingVC":
            guard let vc = segue.destination as? RedPacketVC else { break }
            vc.baker = self.avbaker
            show(vc, sender: sender)
        case "showCheckOutFromShopCheckingVC":
            guard let vc = segue.destination as? OrderCheckOutVC else { break }
            vc.title = "下单成功"
            vc.avbaker = self.avbaker
            vc.avshop = self.avshop
        default:
            break
        }
    }
    
    @IBAction func unwindToShopCheckingVC(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func checkOutBtnPressed(_ sender: Any) {
        makePayment(determineSections(avshop))
    }
    
    func makePayment(_ secs: Int) {
        alertOkayOrNot(okTitle: "支付", notTitle: "取消", msg: "确认支付吗？", okAct: {
            _ in
            switch secs {
            case 2:
                break
            case 3:
                break
            case 4:
                break
            default:
                break
            }
            var avorder = self.avorder
            if avorder == nil {
                avorder = AVOrder()
            }
            self.saveOrderAndBakes(avorder!, with: 0)
        }, notAct: { _ in })
    }
    
    func saveOrderAndBakes(_ order: AVOrder, with type: Int) {
        switch type {
        case 0:
            order.deliveryAddress = self.avaddress
            order.deliveryTime = Date()
        case 1:
            order.deliveryAddress = self.avaddressPreOrder
            order.deliveryTime = self.selectedTime?.date
        default:
            break
        }
        order.baker = self.avbaker
        order.shop = self.avshop
        order.type = type as NSNumber
        order.saveInBackground({
            succeeded, error in
            if succeeded {
                
            } else {
                self.view.notify(text: "下单出现异常，请检查网络后重试！", color: .alertRed, nav: self.navigationController?.navigationBar)
            }
        })
        for bake in self.shopVC.shopBuyVC.avbakesIn.values {
            bake.order = order
            bake.saveInBackground({
                succeeded, error in
                if succeeded {
                    
                } else {
                    self.avorder = nil
                }
            })
        }
        for bake in self.shopVC.shopPreVC.avbakesPre.values {
            bake.order = order
            bake.saveInBackground({
                succeeded, error in
                if succeeded {
                    
                } else {
                    self.avorder = nil
                }
            })
        }
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
            tableView.reloadData()
        case 1:
            bakes = RealmHelper.retrieveAllBakes(avshopID: avshop.objectId!)
            tableView.reloadData()
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
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            switch section {
            case 0:
                if userRealm == nil {
                    return 2
                }
                if segmentedControlDeliveryWay == nil {
                    return 0
                }
                switch segmentedControlDeliveryWay.selectedSegmentIndex {
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
                    return 3
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
            return deliveryDates.count
        case 2:
            return deliveryTimes.count
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
                    self.segmentedControlDeliveryWay = cell.segmentedControlDW
                    let secs = determineSections(avshop)
                    switch secs {
                    case 2:
                        self.segmentedControl.setEnabled(true, forSegmentAt: 0)
                        self.segmentedControl.setEnabled(false, forSegmentAt: 1)
                        self.segmentedControl.setEnabled(false, forSegmentAt: 2)
                        self.segmentedControl.selectedSegmentIndex = 0
                    case 3:
                        self.segmentedControl.setEnabled(false, forSegmentAt: 0)
                        self.segmentedControl.setEnabled(false, forSegmentAt: 1)
                        self.segmentedControl.setEnabled(true, forSegmentAt: 2)
                        self.segmentedControl.selectedSegmentIndex = 2
                    case 4:
                        self.segmentedControl.setEnabled(true, forSegmentAt: 0)
                        self.segmentedControl.setEnabled(true, forSegmentAt: 1)
                        self.segmentedControl.setEnabled(true, forSegmentAt: 2)
                        self.segmentedControl.selectedSegmentIndex = 0
                    default:
                        break
                    }
                    if avshop.deliveryWays!.contains(0) {
                        self.segmentedControlDeliveryWay.setEnabled(true, forSegmentAt: 0)
                    } else {
                        self.segmentedControlDeliveryWay.setEnabled(false, forSegmentAt: 0)
                    }
                    if avshop.deliveryWays!.contains(1) {
                        self.segmentedControlDeliveryWay.setEnabled(true, forSegmentAt: 1)
                    } else {
                        self.segmentedControlDeliveryWay.setEnabled(false, forSegmentAt: 1)
                    }
                    return cell
                case 1:
                    if userRealm == nil {
                        return UITableViewCell.centerTextCell(with: "立即登录", in: .buttonBlue)
                    } else {
                        // delivery time
                        switch segmentedControlDeliveryWay.selectedSegmentIndex {
                        case 0:
                            let segIndex = segmentedControl.selectedSegmentIndex
                            if determineSections(avshop) == 3 && segIndex == 1 || segIndex == 2 {
                                if selectedTime == nil {
                                    return UITableViewCell.centerTextCell(with: "选择预约收货时间", in: .buttonBlue)
                                } else {
                                    return deliveryTimeCell(indexPath, preOrder: true)
                                }
                            } else {
                                return deliveryTimeCell(indexPath)
                            }
                        case 1:
                            return UITableViewCell.centerTextCell(with: "选择预约收货时间", in: .buttonBlue)
                        default:
                            break
                        }
                    }
                case 2:
                    // delivery address
                    var addr: AVAddress? = avaddress
                    var text = "选择收货地址"
                    if segmentedControl.selectedSegmentIndex == 1 {
                        if determineSections(avshop) % 2 == 1 {
                            addr = avaddressPreOrder
                            text = "选择预约收货地址"
                        }
                    } else if segmentedControl.selectedSegmentIndex == 2 {
                        addr = avaddressPreOrder
                        text = "选择预约收货地址"
                    }
                    if let address = addr {
                        return deliveryAddressCell(with: address, indexPath)
                    } else {
                        return UITableViewCell.centerTextCell(with: text, in: .buttonBlue)
                    }
                case 3:
                    let sections = determineSections(avshop)
                    switch segmentedControl.selectedSegmentIndex {
                    case 1:
                        switch sections {
                        case 4:
                            if userRealm != nil {
                                // delivery time
                                if selectedTime == nil {
                                    return UITableViewCell.centerTextCell(with: "选择预约收货时间", in: .buttonBlue)
                                } else {
                                    return deliveryTimeCell(indexPath, preOrder: true)
                                }
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
                                if let address = avaddressPreOrder {
                                    return deliveryAddressCell(with: address, indexPath, preOrder: true)
                                } else {
                                    return UITableViewCell.centerTextCell(with: "选择预约收货地址", in: .buttonBlue)
                                }
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
                        let cell = UITableViewCell.centerTextCell(with: "袋子空空的", in: .bkBlack)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryTimeDateViewCell", for: indexPath) as! DeliveryTimeDateViewCell
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            cell.backgroundColor = UIColor(hex: 0xEFEFEF)
            cell.layer.cornerRadius = 2
            cell.textLabel?.text = deliveryDates[row]
            cell.textLabel?.numberOfLines = 0
            cell.components = deliveryDatecs[row]
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryTimeViewCell", for: indexPath) as! DeliveryTimeViewCell
            let text = deliveryTimes[row]
            cell.deliveryTimeLabel.text = text
            cell.components = deliveryTimecs[row]
            cell.selectedIcon.isHidden = cell.components != selectedTime || selectedTime == nil
            return cell
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
        let price = fee.fixPriceTagFormat()
        checkoutBtn.setTitle(checkoutBtnText + " ¥\(price)", for: .normal)
        cell.priceLabel.text = "¥ \(price)"
        return cell
    }
    
    private func redPacketCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        cell.selectionStyle = .default
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
        cell.nameLabel.text = "配送费" + (preOrder ? " (预)" : "")
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
                cell.nameLabel.text = bake.name + " (预)"
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
        var labelText = ""
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
            labelText = "支付方式"
        case 1:
            labelText = "订单备注"
        case 2:
            labelText = "发票"
        default:
            break
        }
        return UITableViewCell.btnCell(with: labelText)
    }
        
    private func deliveryTimeCell(_ indexPath: IndexPath, preOrder: Bool = false) -> ShopCheckDeliveryTimeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckDeliveryTimeTableViewCell", for: indexPath) as! ShopCheckDeliveryTimeTableViewCell
        cell.arrivalTime.alpha = 0
        if preOrder {
            cell.arrivalTime.alpha = 1
            if let selectedTime = selectedTime {
                let mins = selectedTime.minute!
                let minsText = mins < 10 ? "0\(mins)" : "\(mins)"
                cell.arrivalTime.text = "预约 \(selectedTime.hour!):\(minsText) 前送达"
                cell.deliveryTime.text = "\(selectedTime.month!).\(selectedTime.day!)"
                cell.deliveryTime.textColor = .black
                cell.deliveryTime.sizeToFit()
                cell.arrivalTime.frame.origin.x = cell.deliveryTime.frame.origin.x + cell.deliveryTime.frame.width + 10
            }
        } else {
            cell.deliveryTime.text = "立即配送"
            cell.deliveryTime.sizeToFit()
        }
        return cell
    }
    
    private func deliveryAddressCell(with addr: AVAddress, _ indexPath: IndexPath, preOrder: Bool = false) -> ShopCheckAddressTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckAddressTableViewCell", for: indexPath) as! ShopCheckAddressTableViewCell
        
        let township = addr.township ?? ""
        let streetName = addr.streetName ?? ""
        let streetNo = addr.streetNumber ?? ""
        let aoiName = addr.aoiName ?? ""
        let addrDetailed = addr.detailed ?? ""
        let addrAddr = township + streetName + streetNo + aoiName
        let addrProv = addr.province ?? ""
        let addrCity = addr.city ?? ""
        let addrDistrict = addr.district ?? ""
        let addrText = addrAddr + addrDetailed + " " + addrProv + addrCity + addrDistrict

        cell.phoneLabel.text = addr.phone
        cell.nameLabel.text = addr.name
        
        // dynamic set the text, set number of lines
        cell.addressLabel.text = addrAddr + addrDetailed
        var labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: cell.addressLabel.frame.width, height: CGFloat.infinity)).height))
        let charHeight = lroundf(Float(cell.addressLabel.font.lineHeight))
        if labelHeight / charHeight == 1 {
            cell.addressLabel.text = addrText
            labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: cell.addressLabel.frame.width, height: CGFloat.infinity)).height))
            if labelHeight / charHeight > 1 {
                cell.addressLabel.text = addrAddr + addrDetailed + "\n" + addrProv + addrCity + addrDistrict
            }
        } else {
            cell.addressLabel.text = addrText
        }

        if preOrder {
            if !cell.phoneLabel.text!.contains("(预)") {
                cell.phoneLabel.text = cell.phoneLabel.text! + " (预)"
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
                case 1:
                    if userRealm == nil {
                        // login
                        performSegue(withIdentifier: "showLoginFromShopChecking", sender: self)
                    } else {
                        // delivery time
                        let secs = determineSections(avshop)
                        let segIndex = segmentedControl.selectedSegmentIndex
                        if segIndex == 2 || segIndex == 1 && secs == 3 {
                            deliveryTimeSwitch()
                        }
                    }
                case 3:
                    // delivery time
                     deliveryTimeSwitch()
                case 2, 4:
                    // delivery address
                    let isPreOrder = determineSections(avshop) == 3 && segmentedControl.selectedSegmentIndex == 1
                    deliveryAddressVC.isPreOrder = row == 4 || isPreOrder
                    let segue = UIStoryboardSegue(identifier: "showDeliveryAddressFromShopCheckingVC", source: self, destination: deliveryAddressVC)
                    prepare(for: segue, sender: self)
                default:
                    break
                }
            case 1:
                let secs = determineSections(avshop) / 4
                let rows = segmentedControl.selectedSegmentIndex == 1 ? secs + 1 : 1
                switch row {
                case bakes.count + rows:
                    // red packet
                    if redPacketVC == nil {
                        redPacketVC = RedPacketVC.instantiateFromStoryboard()
                    }
                    let segue = UIStoryboardSegue(identifier: "showRedPacketVCFromShopCheckingVC", source: self, destination: redPacketVC)
                    prepare(for: segue, sender: self)
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
            let cell = tableView.cellForRow(at: indexPath) as! DeliveryTimeDateViewCell
            if let cs = cell.components {
                resetDeliveryTimes(by: cs)
                deliveryTimeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        case 2:
            let cell = tableView.cellForRow(at: indexPath) as! DeliveryTimeViewCell
            if let cs = cell.components {
                selectedTime = cs
                setCheckOutBtn(enabled: true)
                deliveryTimeSwitch()
            }
        default:
            break
        }
    }
    
    func resetDeliveryTimes(by cs: DateComponents) {
        let date = Date()
        let currCs = getDeliveryDateComponents(from: date)
        var startHour = 0
        if cs.month == currCs.month && cs.day == currCs.day {
            let hour = currCs.hour!
            startHour = hour < 9 ? 12 : hour + 3
        } else {
            startHour = 9
        }
        deliveryTimes.removeAll()
        deliveryTimecs.removeAll()
        for i in startHour...19 {
            let timeText = "\(i):00"
            var components = getDeliveryDateComponents(from: date)
            components.weekday = cs.weekday
            components.month = cs.month
            components.day = cs.day
            components.hour = i
            components.minute = 0
            deliveryTimecs.append(components)
            deliveryTimes.append(timeText)
        }
        deliveryTimeTableView.reloadData()
    }
    
    func deliveryTimeSwitch() {
        switch deliveryTimeViewState {
        case .collapsed:
            deliveryTimeViewState = .expanded
            let date = Date()
            let days = avshop.deliveryPreOrderDays as! Int
            deliveryDates.removeAll()
            if days == 0 {
                let cs = getDeliveryDateComponents(from: date)
                if cs.hour! >= 12 {
                    view.notify(text: "暂不接受预订哦。", color: .alertOrange, nav: navigationController?.navigationBar)
                    return
                } else {
                    let dateText = "\(weekdays[cs.weekday!]) \(cs.month!).\(cs.day!) (今天)"
                    deliveryDatecs.append(cs)
                    deliveryDates.append(dateText)
                }
            }
            for i in 1...days {
                let dateToBeAdd = date.addingTimeInterval(TimeInterval(i * 60 * 60 * 24))
                let cs = getDeliveryDateComponents(from: dateToBeAdd)
                var dateText = "\(weekdays[cs.weekday!]) \(cs.month!).\(cs.day!)"
                if i == 1 {
                    dateText += " (明天)"
                }
                deliveryDatecs.append(cs)
                deliveryDates.append(dateText)
            }
            deliveryTimeDateTableView.reloadData()
            deliveryTimeDateTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            resetDeliveryTimes(by: deliveryDatecs[0])
            deliveryTimeTableView.reloadData()
            let bgView = UIView(frame: UIScreen.main.bounds)
            bgView.restorationIdentifier = "bgView"
            bgView.alpha = 0
            bgView.backgroundColor = UIColor(hex: 0x121212, alpha: 0.84)
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopCheckingVC.deliveryTimeSwitchSelector(_:))))
            view.addSubview(bgView)
            view.bringSubview(toFront: deliveryTimeView)
            UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.84, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
                self.deliveryTimeView.alpha = 1
                self.deliveryTimeView.frame.origin.y = screenHeight - self.deliveryTimeView.frame.height
                self.view.layoutIfNeeded()
                bgView.alpha = 1
            }, completion: {
                finished in
                self.deliveryTimeView.alpha = 1
                self.deliveryTimeView.frame.origin.y = screenHeight - self.deliveryTimeView.frame.height
                bgView.alpha = 1
            })
        case .expanded:
            deliveryTimeViewState = .collapsed
            tableView.reloadData()
            view.subviews.forEach({
                if $0.restorationIdentifier == "bgView" {
                    let bgView = $0
                    UIView.animate(withDuration: 0.48, delay: 0, usingSpringWithDamping: 0.84, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                        self.deliveryTimeView.alpha = 0.4
                        self.deliveryTimeView.frame.origin.y = screenHeight
                        self.view.layoutIfNeeded()
                        bgView.alpha = 0
                    }, completion: {
                        finished in
                        self.deliveryTimeView.frame.origin.y = screenHeight
                        self.deliveryTimeView.alpha = 0
                        bgView.removeFromSuperview()
                    })
                    return
                }
            })
        }
    }
    
    func deliveryTimeSwitchSelector(_ sender: UITapGestureRecognizer) {
        deliveryTimeSwitch()
    }
    
    // Height for Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
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
        case 1:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 2, 4:
                    return UITableViewAutomaticDimension
                default:
                    return 44
                }
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
