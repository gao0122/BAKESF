//
//  DeliveryAddressVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/1/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        button.titleLabel!.font = UIFont(name: "System", size: 32)
        return button
    }()
    
    let backBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 15, y: 25, width: 12, height: 20)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backBtnPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    
    var avbaker: AVBaker!
    var addresses: [AVAddress]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeliveryAddressTableCell.self, forCellReuseIdentifier: "deliveryAddressTableCell")
        view.addSubviews([newAddressBtn, tableView, backBtn])
        
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
    }

    func backBtnPressed(_ sender: Any) {
        
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses == nil ? 0 : addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressTableCell", for: indexPath) as! DeliveryAddressTableCell
        let row = indexPath.row
        cell.nameLabel.text = addresses[row].address!
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    class DeliveryAddressTableCell: UITableViewCell {
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 20, y: 30, width: 200, height: 24)
            label.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubview(nameLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
