//
//  DeliveryAddressVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/6/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAddressBtn: UIButton!
    
    
    var deliveryAddressEditingVC: DeliveryAddressEditingVC!
    var addresses: [AVAddress]!
    var shopCheckingVC: ShopCheckingVC!
    var avbaker: AVBaker?
    var editingAddress: AVAddress?
    var selectedAddress: AVAddress?
    var currentAddress: AVAddress?
    
    var hasSelectedCell = false
    
    let errorText = "操作失败，请检查网络连接。"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "选择收货地址"
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let avbaker = self.avbaker {
            let query = AVAddress.query()
            query.includeKey("Baker")
            query.whereKey("Baker", equalTo: avbaker)
            query.findObjectsInBackground({
                objects, error in
                if let error = error {
                    // TODO: - error handling
                    printit(error.localizedDescription)
                    self.view.notify(text: "网络似乎出了点问题...", color: .alertRed, nav: self.navigationController?.navigationBar)
                } else {
                    if let addresses = objects as? [AVAddress] {
                        self.addresses = addresses
                        self.tableView.reloadData()
                    } else {
                        // TODO: - error handling
                        self.view.notify(text: "发生未知错误，请尝试刷新。", color: .alertRed, nav: self.navigationController?.navigationBar)
                    }
                }
            })
        }
    }

    class func instantiateFromStoryboard() -> DeliveryAddressVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressVC
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else { return }
        switch id {
        case "unwindToShopCheckingVCFromDeliveryAddress":
            guard let vc = segue.destination as? ShopCheckingVC else { break }
            if hasSelectedCell {
                hasSelectedCell = false
                vc.avaddress = selectedAddress
            }
        case "showDeliveryAddressEditingVCFromDAVC", "showDeliveryAddressEditingVCFromDAVCForAdding":
            deliveryAddressEditingVC.avbaker = self.avbaker
            show(deliveryAddressEditingVC, sender: sender)
        default:
            break
        }
    }

    
    @IBAction func unwindToDeliveryAddressVC(segue: UIStoryboardSegue) {
        
    }

    @IBAction func addAddressBtnPressed(_ sender: Any) {
        if deliveryAddressEditingVC == nil {
            deliveryAddressEditingVC = DeliveryAddressEditingVC.instantiateFromStoryboard()
        }
        deliveryAddressEditingVC.address = nil
        let segue = UIStoryboardSegue(identifier: "showDeliveryAddressEditingVCFromDAVCForAdding", source: self, destination: deliveryAddressEditingVC)
        prepare(for: segue, sender: sender)
    }
    
    
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses == nil ? 0 : addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressTableViewCell") as! DeliveryAddressTableViewCell
        let row = indexPath.row
        let addr = addresses[row]
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
        
        // dynamic set the text, set number of lines
        cell.addressLabel.text = addrAddr
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
        
        cell.nameLabel.text = addr.name ?? ""
        cell.phoneLabel.text = addr.phone ?? ""
        cell.address = addr
        cell.editBtn.addTarget(self, action: #selector(editBtnPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    func editBtnPressed(sender: UIButton) {
        guard let cell = sender.superview?.superview as? DeliveryAddressTableViewCell else { return }
        if deliveryAddressEditingVC == nil {
            deliveryAddressEditingVC = DeliveryAddressEditingVC.instantiateFromStoryboard()
        }
        deliveryAddressEditingVC.address = cell.address
        let segue = UIStoryboardSegue(identifier: "showDeliveryAddressEditingVCFromDAVC", source: self, destination: deliveryAddressEditingVC)
        prepare(for: segue, sender: sender)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let address = addresses[row]
        selectedAddress = address
        hasSelectedCell = true
        if let lastAddress = shopCheckingVC.avaddress {
            lastAddress.recentlyUsed = false
            lastAddress.saveInBackground({
                succeeded, error in
                if succeeded {
                    address.recentlyUsed = true
                    address.saveInBackground({
                        succeeded, error in
                        tableView.deselectRow(at: indexPath, animated: true)
                        if succeeded {
                            self.performSegue(withIdentifier: "unwindToShopCheckingVCFromDeliveryAddress", sender: tableView)
                        } else {
                            self.view.notify(text: self.errorText, color: .alertRed, nav: self.navigationController?.navigationBar)
                        }
                    })
                } else {
                    self.view.notify(text: self.errorText, color: .alertRed, nav: self.navigationController?.navigationBar)
                }
            })
        } else {
            address.recentlyUsed = true
            address.saveInBackground({
                succeeded, error in
                tableView.deselectRow(at: indexPath, animated: true)
                if succeeded {
                    self.performSegue(withIdentifier: "unwindToShopCheckingVCFromDeliveryAddress", sender: tableView)
                } else {
                    self.view.notify(text: self.errorText, color: .alertRed, nav: self.navigationController?.navigationBar)
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
}
