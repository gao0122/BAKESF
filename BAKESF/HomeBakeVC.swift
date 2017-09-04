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
    
    var homeVC: HomeVC!
    
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
                self.homeVC.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重试。")
            }
        })
    }
    
    func loadBakes() {
        loadBakes({
            bakes, error in
            if let bakes = bakes {
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.categories = nil
                self.refresher.endRefreshing()
                self.homeVC.showLocateFailedViewAndStopIndicator(with: "商品获取失败，请重新尝试。")
            }
        })
    }
    
    func loadBakes(_ completion: @escaping ([AVBake]?, Error?) -> ()) {
        let query = AVBake.query()
        query.addAscendingOrder("priority")
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
        return cell
    }
    
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            break
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeBakeCollectionViewCell", for: indexPath) as! HomeBakeCollectionViewCell
        cell.imageView.image = UIImage(named: "seller3_hp")
        return cell
    }
}
