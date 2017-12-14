//
//  HomeBakeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

class HomeBakeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [AVObject]?
    var bakesDict = [String: [AVBake]]()
    
    var homeVC: HomeVC?
    var bakeDict = [Int: [AVBake]]()
    var bakeDetailDict = [AVBake: [AVBakeDetail]]()
    
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(HomeBakeVC.sellerRefresh(_:)), for: UIControlEvents.valueChanged)
        return refresher
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white

        tableView.addSubview(refresher)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
     
        
    }

    override func viewDidAppear(_ animated: Bool) {
        refresher.beginRefreshing()
        loadCategories()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    class func instantiateFromStoryboard() -> HomeBakeVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! HomeBakeVC
    }
 
    func sellerRefresh(_ sender: Any) {
        loadCategories()
    }
    
    func loadCategories() {
        let query = AVQuery(className: "HomeBakeCategory")
        query.addAscendingOrder("priority")
        query.findObjectsInBackground({
            objects, error in
            if let categories = objects as? [AVObject] {
                self.categories = categories
                self.loadBakes()
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC?.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重试。")
            }
        })
    }
    
    func loadBakes() {
        self.bakeDict = [Int: [AVBake]]()
        self.loadBakes({
            bakes, error in
            if let bakes = bakes {
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                self.bakeDict[0] = bakes
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC?.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重新尝试。")
            }
        }, category: "甜点")
        
        self.loadBakes({
            bakes, error in
            if let bakes = bakes {
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                self.bakeDict[1] = bakes
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC?.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重新尝试。")
            }
        }, category: "蛋糕")
        
        self.loadBakes({
            bakes, error in
            if let bakes = bakes {
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                self.bakeDict[2] = bakes
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC?.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重新尝试。")
            }
        }, category: "面包")
        
        self.loadBakes({
            bakes, error in
            if let bakes = bakes {
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                self.bakeDict[3] = bakes
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC?.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重新尝试。")
            }
        }, category: "其他")
    }
    
    func loadBakes(_ completion: @escaping ([AVBake]?, Error?) -> (), category: String) {
        let query = AVBake.query()
        query.includeKey("image")
        query.includeKey("shop")
        query.includeKey("defaultBake")
        query.addAscendingOrder("priority")
        if category != "" {
            query.whereKey("category", equalTo: category)
        }
        query.limit = 7
        query.findObjectsInBackground({
            objects, error in
            completion(objects as? [AVBake], error)
        })
    }

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeBakeTableViewCell", for: indexPath) as! HomeBakeTableViewCell
        guard let categories = categories else { return cell }
        guard let category = categories[row].object(forKey: "name") as? String else { return cell }
        cell.categoryLabel.text = category
        cell.collectionView.tag = row
        cell.collectionView.reloadData()
        return cell
    }
    
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bakeDict[collectionView.tag]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeBakeCollectionViewCell", for: indexPath) as! HomeBakeCollectionViewCell
        let tag = collectionView.tag
        let itm = indexPath.item
        let bakes = bakeDict[tag]!
        let bake = bakes[itm]
        guard let defaultBake = bake.defaultBake else { return cell }
        cell.nameLabel.text = bake.name
        if let price = defaultBake.price as? Double {
            cell.priceLabel.text = "¥\(price.fixPriceTagFormat())"
        } else {
            cell.priceLabel.text = ""
        }
        cell.priceLabel.sizeToFit()
        cell.priceLabel.frame.origin.x = cell.frame.width - cell.priceLabel.frame.size.width - 2
        cell.nameLabel.frame.size.width = cell.priceLabel.frame.origin.x - 3
        if let url = bake.image?.url {
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.sd_setImage(with: URL(string: url), completed: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = collectionView.tag
        let itm = indexPath.item
        let bakes = bakeDict[tag]!
        let bake = bakes[itm]
    }
    
}
