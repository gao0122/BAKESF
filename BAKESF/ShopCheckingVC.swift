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
    
    var isInBag: Bool = true
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
    var avorder = AVOrder()
    
    var bakes: [Object]!
    var deliveryTimeViewState: DeliveryTimeViewState = .collapsed
    var deliveryDatecs = [DateComponents]()
    var deliveryDates = [String]()
    var deliveryTimecs = [DateComponents]()
    var deliveryTimes = [String]()
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
        if isInBag {
            bakes = RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        } else {
            bakes = RealmHelper.retrieveBakesPreOrder(avshopID: avshop.objectId!).sorted(by: { _, _ in return true })
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.tableFooterView = footerView
        deliveryTimeDateTableView.tableFooterView = footerView
        deliveryTimeTableView.tableFooterView = footerView
        
    }

    override func viewWillAppear(_ animated: Bool) {
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
                            self.setCheckOutBtn(enabled: false)
                            printit("Retrieve address error: \(error.localizedDescription)")
                        } else {
                            if let addresses = objects as? [AVAddress] {
                                self.avaddress = nil
                                for address in addresses {
                                    if self.isInBag {
                                        if address.isForRightNow {
                                            self.avaddress = address
                                        }
                                    } else {
                                        if address.isForPreOrder {
                                            self.avaddress = address
                                        }
                                    }
                                }
                                self.setCheckOutBtn(enabled: true)
                            } else {
                                self.avaddress = nil
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
        let enabled = enabled && selectedTime != nil
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
        alertOkayOrNot(okTitle: "支付", notTitle: "取消", msg: "确认支付吗？", okAct: {
            _ in
            self.saveOrderAndBakes()
        }, notAct: { _ in })
    }
    
    func saveOrderAndBakes() {
        let group = DispatchGroup()
        avorder = AVOrder()
        avorder.deliveryAddress = self.avaddress
        avorder.predictionDeliveryTime = self.selectedTime?.date
        avorder.baker = self.avbaker
        avorder.shop = self.avshop
        avorder.type = (isInBag ? 0 : 1) as NSNumber

        group.enter()
        avorder.saveInBackground({
            succeeded, error in
            if succeeded {
                group.leave()
                if self.isInBag {
                    for bake in self.shopVC.shopBuyVC.avbakesIn.values {
                        bake.order = self.avorder
                        group.enter()
                        bake.saveInBackground({
                            succeeded, error in
                            if succeeded {
                                group.leave()
                            } else {
                                printit("error: \(error!.localizedDescription)")
                                group.leave()
                            }
                        })
                    }
                } else {
                    for bake in self.shopVC.shopPreVC.avbakesPre.values {
                        bake.order = self.avorder
                        group.enter()
                        bake.saveInBackground({
                            succeeded, error in
                            if succeeded {
                                group.leave()
                            } else {
                                printit("error: \(error!.localizedDescription)")
                                group.leave()
                            }
                        })
                    }
                }
            } else {
                group.leave()
                self.view.notify(text: "下单出现异常，请检查网络后重试！", color: .alertRed, nav: self.navigationController?.navigationBar)
            }
        })

        group.notify(queue: DispatchQueue.main, execute: {
            // all completed
        })
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
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
                if userRealm == nil { return 2 }
                if segmentedControlDeliveryWay == nil { return 1 }
                return 3
            case 1:
                if segmentedControlDeliveryWay == nil { return bakes.count + 2 }
                return bakes.count + 3 // 配送费，红包，总计
            case 2:
                return tableSectionOtherCell.count // 支付方式，订单备注，发票
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
                    if avshop.deliveryWays!.contains(0) {
                        cell.segmentedControl.setEnabled(true, forSegmentAt: 0)
                        if self.segmentedControlDeliveryWay == nil {
                            cell.segmentedControl.selectedSegmentIndex = 0
                        }
                    } else {
                        cell.segmentedControl.setEnabled(false, forSegmentAt: 0)
                        if avshop.deliveryWays!.contains(1) {
                            cell.segmentedControl.setEnabled(true, forSegmentAt: 1)
                            if self.segmentedControlDeliveryWay == nil {
                                cell.segmentedControl.selectedSegmentIndex = 1
                            }
                        } else {
                            cell.segmentedControl.setEnabled(false, forSegmentAt: 1)
                        }
                    }
                    self.segmentedControlDeliveryWay = cell.segmentedControl
                    return cell
                case 1:
                    if userRealm == nil {
                        return UITableViewCell.centerTextCell(with: "立即登录", in: .buttonBlue)
                    } else {
                        // delivery time
                        switch segmentedControlDeliveryWay.selectedSegmentIndex {
                        case 0:
                            if selectedTime == nil {
                                let text = isInBag ? "选择收货时间" : "选择预约收货时间"
                                return UITableViewCell.centerTextCell(with: text, in: .buttonBlue)
                            } else {
                                return deliveryTimeCell(indexPath)
                            }
                        case 1:
                            return UITableViewCell.centerTextCell(with: "选择自取时间", in: .buttonBlue)
                        default:
                            break
                        }
                    }
                case 2:
                    // delivery address
                    if let address = self.avaddress {
                        return deliveryAddressCell(with: address, indexPath)
                    } else {
                        let text = isInBag ? "选择收货地址" : "选择预约收货地址"
                        return UITableViewCell.centerTextCell(with: text, in: .buttonBlue)
                    }
                default:
                    break
                }
            case 1:
                switch row {
                case bakes.count:
                    return deliveryFeeCell(indexPath)
                case bakes.count + 1:
                    return redPacketCell(indexPath)
                case bakes.count + 2:
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
        if isInBag {
            fee += RealmHelper.retrieveBakesInBagCost(avshopID: avshop.objectId!)
        } else {
            fee += RealmHelper.retrieveBakesPreOrderCost(avshopID: avshop.objectId!)
        }
        cell.priceLabel.alpha = 1
        cell.nameLabel.alpha = 0
        cell.amountLabel.alpha = 1
        cell.amountLabel.text = "总计"
        let price = fee.fixPriceTagFormat()
        cell.priceLabel.text = "¥ \(price)"
        checkoutBtn.setTitle(checkoutBtnText + " ¥\(fee.fixPriceTagFormat())", for: .normal)
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
    
    private func deliveryFeeCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        guard let fee = avshop.deliveryFee as? Double else { return cell }
        cell.priceLabel.alpha = 1
        cell.nameLabel.alpha = 1
        cell.amountLabel.alpha = 0
        cell.nameLabel.text = "配送费"
        cell.priceLabel.text = "¥ \(fee.fixPriceTagFormat())"
        return cell
    }
    
    private func bakeItemCell(_ indexPath: IndexPath) -> ShopCheckBakeTableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckBakeTableViewCell", for: indexPath) as! ShopCheckBakeTableViewCell
        cell.amountLabel.alpha = 1
        cell.priceLabel.alpha = 1
        cell.nameLabel.alpha = 1
        if isInBag {
            guard let bake = bakes[row] as? BakeInBagRealm else { return cell }
            cell.nameLabel.text = bake.name
            cell.amountLabel.text = "×\(bake.amount)"
            cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
        } else {
            guard let bake = bakes[row] as? BakePreOrderRealm else { return cell }
            cell.nameLabel.text = bake.name
            cell.amountLabel.text = "×\(bake.amount)"
            cell.priceLabel.text = "¥ \((bake.price * Double(bake.amount)).fixPriceTagFormat())"
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
        labelText = tableSectionOtherCell[indexPath.row]!
        return UITableViewCell.btnCell(with: labelText)
    }
        
    private func deliveryTimeCell(_ indexPath: IndexPath) -> ShopCheckDeliveryTimeTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckDeliveryTimeTableViewCell", for: indexPath) as! ShopCheckDeliveryTimeTableViewCell
        if isInBag {
            cell.arrivalTime.alpha = 0
            cell.deliveryTime.text = "立即配送"
            cell.deliveryTime.sizeToFit()
        } else {
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
        }
        return cell
    }
    
    private func deliveryAddressCell(with addr: AVAddress, _ indexPath: IndexPath) -> ShopCheckAddressTableViewCell {
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

        cell.nameLabel.sizeToFit()
        cell.phoneLabel.sizeToFit()
        return cell
    }
    
    
    // Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControlDeliveryWay == nil { return }
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
                        deliveryTimeSwitch()
                    }
                case 2:
                    // delivery address
                    deliveryAddressVC.isPreOrder = !isInBag
                    let segue = UIStoryboardSegue(identifier: "showDeliveryAddressFromShopCheckingVC", source: self, destination: deliveryAddressVC)
                    prepare(for: segue, sender: self)
                default:
                    break
                }
            case 1:
                switch row {
                case bakes.count + 1:
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
                case 2:
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
                case 2:
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

private let tableSectionOtherCell: [Int: String] = [
    0: "支付方式",
    1: "订单备注",
    2: "发票"
]
