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
    var avbaker: AVBaker!
    var selectedAddr: AVAddress!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        let query = AVAddress.query()
        query.includeKey("Baker")
        query.whereKey("Baker", equalTo: avbaker)
        query.findObjectsInBackground({
            objects, error in
            if let error = error {
                // TODO: - error handling
                printit(error.localizedDescription)
            } else {
                if let addresses = objects as? [AVAddress] {
                    self.addresses = addresses
                    self.tableView.reloadData()
                } else {
                    // TODO: - error handling
                }
            }
        })
        
        
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
            break
        case "showDeliveryAddressEditingVCFromDAVC":
            show(deliveryAddressEditingVC, sender: self)
        default:
            break
        }
    }

    
    @IBAction func unwindToDeliveryAddressVC(segue: UIStoryboardSegue) {
        
    }

    @IBAction func addAddressBtnPressed(_ sender: Any) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressTableCell") as! DeliveryAddressTableViewCell
        let row = indexPath.row
        let addr = addresses[row]
        let addrAddr = addr.address!
        let addrProv = addr.province!
        let addrCity = addr.city!
        let addrDistrict = addr.district!
        let addrText = addrAddr + " " + addrProv + addrCity + addrDistrict
        
        // dynamic set the text, set number of lines
        var labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: cell.addressLabel.frame.width, height: CGFloat.infinity)).height))
        let charHeight = lroundf(Float(cell.addressLabel.font.lineHeight))
        cell.addressLabel.text = addrAddr
        if labelHeight / charHeight == 1 {
            cell.addressLabel.text = addrText
            labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: cell.addressLabel.frame.width, height: CGFloat.infinity)).height))
            if labelHeight / charHeight > 1 {
                cell.addressLabel.text = addrAddr + "\n" + addrProv + addrCity + addrDistrict
            }
        } else {
            cell.addressLabel.text = addrText
        }
        
        cell.nameLabel.text = addr.name!
        cell.phoneLabel.text = addr.phone!
        cell.selectionStyle = .none
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
        prepare(for: segue, sender: self)
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
