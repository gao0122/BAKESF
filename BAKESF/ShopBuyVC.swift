//
//  ShopBuyVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudLiveQuery

class ShopBuyVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, AVLiveQueryDelegate {

    @IBOutlet weak var classifyTableView: ShopClassifyTableView!
    @IBOutlet weak var bakeTableView: ShopBuyBakeTableView!
    
    let cartBarHeight: CGFloat = 50
    var shopView: UIView!
    var originShopY: CGFloat!
    var buyBake = [Int]()
    var avcategory: [String]!
    var avshop: AVShop!
    var avbakes: [AVBake]!
    var bakeLiveQuery: AVLiveQuery!
    var tableFooterView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        avcategory = avshop.categories!

        classifyTableView.isScrollEnabled = false
        tableFooterView.frame.size.width = bakeTableView.frame.width
        tableFooterView.frame.size.height = cartBarHeight
        bakeTableView.tableFooterView = tableFooterView

        let shopQuery = AVBake.query()
        shopQuery.whereKey("Shop", equalTo: avshop)
        let buyQuery = AVBake.query()
        buyQuery.whereKey("stock", equalTo: 0) // only for buy
        let bothQuery = AVBake.query()
        bothQuery.whereKey("stock", equalTo: 2) // for buy or book
        let orQuery = AVQuery.orQuery(withSubqueries: [buyQuery, bothQuery])
        let query = AVQuery.andQuery(withSubqueries: [shopQuery, orQuery])
        query.includeKey("image")
        query.findObjectsInBackground({
            objects, error in
            if error == nil {
                self.avbakes = objects as! [AVBake]
                self.bakeTableView.reloadData()
            } else {
                printit(any: "shop buy vc \(error!.localizedDescription)")
            }
        })
        
        realtimeCheckBake()
    }

    class func instantiateFromStoryboard() -> ShopBuyVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! ShopBuyVC
    }
    
    
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0: // classify table
            return 1
        case 1: // bake table
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = classifyTableView.dequeueReusableCell(withIdentifier: "shopClassifyTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopClassifyTableCell
            cell.selectionStyle = .none
            cell.classLabel.text = avcategory[indexPath.row]
            return cell
        case 1:
            let cell = bakeTableView.dequeueReusableCell(withIdentifier: "shopBuyBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopBuyBakeTableCell
            cell.selectionStyle = .none
            
            let bakee = avbakes[indexPath.row]
            
            let bakeName = bakee.name!
            let price = bakee.price!
            let left = bakee["amount"] as! Int
            // let star =

            cell.bake = bakee
            cell.bakeImage.contentMode = .scaleAspectFill
            if bakee.image == nil {
                printit(any: "\n\n\n\(bakee.name!)\n\n\n")
            }
            cell.bakeImage.sd_setImage(with: URL(string: bakee.image?.url ?? ""))
            cell.bakeImage.clipsToBounds = true
            cell.bakeImage.layer.cornerRadius = 3
            cell.nameLabel.text = bakeName
            cell.priceLabel.text = "¥\(price)"
            cell.leftLabel.text = "剩余 \(left)"
            cell.oneMoreBtn.addTarget(self, action: #selector(ShopBuyVC.oneMorePressed(_:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView.tag {
        case 0:
            count = avcategory.count
        case 1:
            count = avbakes == nil ? 0 : avbakes.count
        default:
            break
        }
        return count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag != 1 { return }
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shopView.frame.origin.y == originShopY {
            bakeTableView.shouldScroll = false
        }
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
    
    func oneMorePressed(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? ShopBuyBakeTableCell {
            printit(any: cell.bake.name)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: - realtime load bakes
    func realtimeCheckBake() {
        let bakeQuery = AVQuery(className: "Bake")
        bakeQuery.includeKey("Shop")
        bakeQuery.whereKey("Shop", equalTo: avshop)
        bakeLiveQuery = AVLiveQuery(query: bakeQuery)
        bakeLiveQuery.delegate = self
        bakeLiveQuery.subscribe(callback: {
            succeeded, error in
            if succeeded {
            } else {
                // TODO: - handle error
                printit(any: error.localizedDescription)
            }
        })
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        
    }


}
