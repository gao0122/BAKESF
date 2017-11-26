//
//  HomeShopVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import QuartzCore
import AVOSCloud
import AVOSCloudLiveQuery
import SDWebImage

class HomeShopVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    let TEST = true

    @IBOutlet weak var tableView: HomeShopTableView!
    
    var avshops = [AVShop]()
    
    var homeVC: HomeVC!
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
        
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white

        tableView.addSubview(refresher)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 5))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadShops()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    class func instantiateFromStoryboard() -> HomeShopVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! HomeShopVC
    }
    
    func loadShops() {
        loadShops({
            shops, error in
            self.refresher.endRefreshing()
            if let shops = shops {
                self.avshops = shops
                self.tableView.reloadData()
            } else {
                self.homeVC.showLocateFailedViewAndStopIndicator(with: "商家获取失败，请重试。")
            }
        })
    }
    
    func sellerRefresh(_ sender: UIRefreshControl) {
        loadShops({
            shops, error in
            self.refresher.endRefreshing()
            if let shops = shops {
                // refreshed
                self.avshops = shops
                self.tableView.reloadData()
            } else {
                self.homeVC.showLocateFailedViewAndStopIndicator(with: "商家获取失败，请重试。")
            }
        })
    }
    
    
    /// Loading all shops from LeanCloud
    ///
    /// - Parameter completion: A compleion block executed after it loaded all shops.
    func loadShops(_ completion: @escaping ([AVShop]?, Error?) -> ()) {
        let sellersQuery = AVShop.query()
        sellersQuery.includeKey("baker") // key code: including all data inside Baker table but not only a pointer
        sellersQuery.includeKey("bgImage")
        sellersQuery.includeKey("address")
        sellersQuery.includeKey("headphoto")
        sellersQuery.limit = sellersPerPage
        sellersQuery.skip = currentPage * sellersPerPage
        sellersQuery.findObjectsInBackground({
            objects, error in
            if var shops = objects as? [AVShop] {
                if !self.TEST {
                    shops = shops.filter({
                        shop in
                        let open = Date().isTimeBetween(from: shop.openTime, to: shop.closeTime)
                        let status = shop.status
                        let isSameCity = shop.address!.city == self.homeVC.locationRealm!.city
                        return open && status && isSameCity
                    })
                }
                if shops.count == 0 {
                    self.homeVC.showLocateFailedViewAndStopIndicator(with: self.homeVC.noShopsText)
                }
                completion(shops, error)
            } else {
                completion(nil, error)
            }
        })
    }
    

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeShopTableViewCell") as! HomeShopTableViewCell
        
        cell.selectionStyle = .none
        
        let shop = avshops[indexPath.row]
        cell.nameLabel.text = shop["name"] as? String
        
        cell.commentsNumber.setTitle("\(423) 评论", for: .normal)
        
        if let url = shop.headphoto?.url {
            let hpUrl = URL(string: url)
            cell.headphoto.sd_setImage(with: hpUrl)
            cell.headphoto.contentMode = .scaleAspectFill
            cell.headphoto.clipsToBounds = true
            cell.headphoto.layer.cornerRadius = cell.headphoto.frame.size.width / 2
            cell.headphoto.layer.masksToBounds = true
        }
        
        if let url = shop.bgImage?.url {
            let bgUrl = URL(string: url)
            cell.bgImage.sd_setImage(with: bgUrl)
            cell.bgImage.frame.origin = CGPoint(x: 0, y: 0)
            cell.bgImage.contentMode = .scaleAspectFill
            cell.bgImage.clipsToBounds = true
        }
        let starsSize = CGSize(width: starHeightInHomeVC * 5, height: starHeightInHomeVC)
        cell.stars.frame.size = starsSize
        cell.starsGray.frame = cell.stars.frame
        let width = starHeightInHomeVC * 5
        let star: CGFloat = 4.4
        let x = calStarsWidth(byStarWidth: width, stars: star)
        cell.stars.contentMode = .scaleAspectFill
        cell.stars.image = UIImage(named: "five_stars")!.cropTo(x: 0, y: 0, width: x * 3, height: cell.stars.frame.height * 3, bounds: false)
        cell.stars.frame.size.width = x
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avshops.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if refresher.isRefreshing {
            refresher.endRefreshing()
        }
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
                    sellerVC.avshop = avshops[tableView.indexPathForSelectedRow!.row]
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToHomeShopVC(segue: UIStoryboardSegue) {
        segue.source.tabBarController?.tabBar.isHidden = false
        segue.source.tabBarController?.tabBar.frame.origin.y = screenHeight

    }
    
}

