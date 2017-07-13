//
//  HomeShopVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import QuartzCore
import LeanCloud
import AVOSCloud
import AVOSCloudLiveQuery
import SDWebImage

class HomeShopVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: HomeShopTableView!
    
    var shops: [String: Any]!
    var avshops = [AVShop]()
    
    let sellersPerPage = 5
    var currentPage = 0
    
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(HomeShopVC.sellerRefresh(_:)), for: UIControlEvents.valueChanged)
        return refresher
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refresher)
        
        
        loadShops({
            shops, error in
            if error == nil {
                self.avshops = shops!
                self.tableView.reloadData()
            }
        })

        self.shops = theShops
        
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
    
    class func instantiateFromStoryboard() -> HomeShopVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! HomeShopVC
    }
    
    func sellerRefresh(_ sender: UIRefreshControl) {
        loadShops({
            shops, error in
            if error == nil {
                // refreshed
                self.avshops = shops!
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            } else {
                // failed
                self.refresher.endRefreshing()
            }
        })
    }
    
    
    /// Loading all shops from LeanCloud
    ///
    /// - Parameter completion: A compleion block executed after it loaded all shops
    func loadShops(_ completion: @escaping ([AVShop]?, Error?) -> ()) {
        let sellersQuery = AVShop.query()
        sellersQuery.includeKey("Baker") // key code: including all data inside Baker table but not only a pointer
        sellersQuery.includeKey("bgImage")
        sellersQuery.includeKey("headphoto")
        sellersQuery.limit = sellersPerPage
        sellersQuery.skip = currentPage * sellersPerPage
        sellersQuery.findObjectsInBackground({
            objects, error in
            if error == nil {
                completion(objects as? [AVShop], nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    func loadImages() {
        
    }
    
    

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeShopTableViewCell") as! HomeShopTableViewCell
        
        cell.selectionStyle = .none
        
        let shop = avshops[indexPath.row]
        let bgUrl = URL(string: shop.bgImage!.url!)
        let hpUrl = URL(string: shop.headphoto!.url!)
        cell.nameLabel.text = (shop["name"] as! String)
        
        cell.commentsNumber.setTitle("\(423) 评论", for: .normal)
        
        cell.headphoto.sd_setImage(with: hpUrl)
        cell.headphoto.contentMode = .scaleAspectFill
        cell.headphoto.clipsToBounds = true
        cell.headphoto.layer.cornerRadius = cell.headphoto.frame.size.width / 2
        cell.headphoto.layer.masksToBounds = true

        cell.bgImage.sd_setImage(with: bgUrl)
        cell.bgImage.contentMode = .scaleAspectFill
        cell.bgImage.clipsToBounds = true
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avshops.count
    }
    
    
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "homeToShop":
                let sourceVC = segue.source
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                if let sellerVC = segue.destination as? ShopVC {
                    let cell = sender as! HomeShopTableViewCell
                    sellerVC.id = tableView.indexPathForSelectedRow!.row
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToHomeShopVC(segue: UIStoryboardSegue) {
        segue.source.tabBarController?.tabBar.isHidden = false
    }
    
}

