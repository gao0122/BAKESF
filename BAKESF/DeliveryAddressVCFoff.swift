//
//  DeliveryAddressVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/1/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressVCFoff: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 20, width: screenWidth, height: 44)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "选择收货地址"
        label.textColor = .bkBlack
        return label
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.frame = CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 64 - 50)
        return tv
    }()
    
    let newAddressBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 50)
        button.backgroundColor = .appleGreen
        button.setTitle("＋", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let backBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 15, y: 32, width: 12, height: 20)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backBtnPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    
    var shopCheckingVC: ShopCheckingVC!
    var avbaker: AVBaker!
    var addresses: [AVAddress]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(hex: 0xefefef)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeliveryAddressTableCell.self, forCellReuseIdentifier: "deliveryAddressTableCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 78
        view.addSubviews([titleLabel, newAddressBtn, tableView, backBtn])
        
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else { return }
        switch id {
        case "unwindToShopCheckingVCFromDeliveryAddress":
            navigationController?.popToViewController(shopCheckingVC, animated: true)
        default:
            break
        }
    }

    func backBtnPressed(_ sender: Any) {
        let unwindSegue = UIStoryboardSegue.init(identifier: "unwindToShopCheckingVCFromDeliveryAddress", source: self, destination: shopCheckingVC)
        prepare(for: unwindSegue, sender: self)
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses == nil ? 0 : addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressTableCell") as! DeliveryAddressTableCell
        let row = indexPath.row
        let addr = addresses[row]
        cell.addressLabel.text = addr.formatted!
        cell.nameLabel.text = addr.name!
        cell.phoneLabel.text = addr.phone!
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    class DeliveryAddressTableCell: UITableViewCell {
        
        let addressLabel: UILabel = {
            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 15, y: -10, width: screenWidth - 30, height: 24)
            label.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            label.font = .boldSystemFont(ofSize: 17)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 2
            return label
        }()
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 20, y: 40, width: 180, height: 20)
            label.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            label.adjustsFontSizeToFitWidth = true
            label.font = UIFont(name: "System", size: 16)
            return label
        }()
        
        let phoneLabel: UILabel = {
            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 200, y: 20, width: 200, height: 20)
            label.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            label.font = UIFont(name: "System", size: 16)
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubview(addressLabel)
            addSubview(nameLabel)
            addSubview(phoneLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
