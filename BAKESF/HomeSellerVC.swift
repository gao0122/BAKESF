//
//  HomeSellerVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore
import LeanCloud

class HomeSellerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: HomeSellerTableView!
    
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "下拉刷新")
        refresher.addTarget(self, action: #selector(HomeSellerVC.sellerRefresh(_:)), for: UIControlEvents.valueChanged)
        return refresher
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    class func instantiateFromStoryboard() -> HomeSellerVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! HomeSellerVC
    }
    
    
    func sellerRefresh(_ sender: UIRefreshControl) {
        tableView.reloadData()
        refresher.endRefreshing()
    }
    

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeSellerTableViewCell") as! HomeSellerTableViewCell
        
        cell.selectionStyle = .none
        
        let seller = sellers["\(indexPath.row)"] as! [String: Any]
        
        cell.nameLabel.text = (seller["name"] as! String)
        
        let commentsNum = seller["commentsNum"] as! Int
        cell.commentsNumber.setTitle("\(commentsNum) 评论", for: .normal)
        
        let hpName = "seller\(indexPath.row)_hp"
        cell.headphoto.image = UIImage(named: hpName)
        cell.headphoto.contentMode = .scaleAspectFill
        cell.headphoto.clipsToBounds = true
        cell.headphoto.layer.cornerRadius = cell.headphoto.frame.size.width / 2
        cell.headphoto.layer.masksToBounds = true
        
        let bgName = "seller\(indexPath.row)_bg"
        cell.bgImage.image = UIImage(named: bgName)
        cell.bgImage.contentMode = .scaleAspectFill
        cell.bgImage.clipsToBounds = true
        
        cell.followBlurView.layer.cornerRadius = 5
        cell.followBlurView.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sellers.count
    }
    
    
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "homeToSeller":
                let sourceVC = segue.source
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                if let sellerVC = segue.destination as? SellerVC {
                    sellerVC.id = tableView.indexPathForSelectedRow!.row
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToHomeSellerVC(segue: UIStoryboardSegue) {
        segue.source.tabBarController?.tabBar.isHidden = false
    }
    
}
