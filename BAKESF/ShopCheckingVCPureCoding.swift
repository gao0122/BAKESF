//
//  ShopCheckingVCPureCoding.swift
//  BAKESF
//
//  Created by 高宇超 on 7/28/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit


// have fun. 

class ShopCheckingVCPureCoding: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let backBtn: UIButton = {
        let button = UIButton()
        let backImg = UIImage(named: "back")
        button.setImage(backImg, for: .normal)
        button.frame = CGRect(x: 20, y: 30, width: 10, height: 16)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        var rect = UIScreen.main.bounds
        rect.origin.y += 64
        tableView.frame = rect
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.autoresizingMask = [.flexibleWidth, .flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        return tableView
    }()
    
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var bakesInBag: [BakeInBagRealm]!
    var bakesPreOrder: [BakePreOrderRealm]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubviews([tableView, backBtn])
        view.bringSubview(toFront: backBtn)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShopCheckTableCell.self, forCellReuseIdentifier: "shopCheckTableCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        //return RealmHelper.retrieveBakesInBag(avshopID: avshop.objectId!).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCheckTableCell", for: indexPath) as! ShopCheckTableCell
        
        return cell
    }

    // MARK: - Table Cell Classes
    //
    class ShopCheckTableCell: UITableViewCell {
        
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 15, y: 10, width: 100, height: 30)
            label.translatesAutoresizingMaskIntoConstraints = true
            label.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubview(label)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class ShopCheckBakeTableCell: UITableViewCell {
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 15, y: 10, width: 100, height: 30)
            label.translatesAutoresizingMaskIntoConstraints = true
            label.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
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
