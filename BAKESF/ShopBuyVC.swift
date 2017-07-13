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

    @IBOutlet weak var tableviewContainer: UIView!
    @IBOutlet weak var classifyTableView: ShopClassifyTableView!
    @IBOutlet weak var bakeTableView: ShopBuyBakeTableView!
    
    var shopView: UIView!
    var originShopY: CGFloat!
    var bake: [String: Any]!
    var bakes: [String: Any]!
    var buyBake = [Int]()
    
    var avshop: AVShop!
    
    var bakeLiveQuery: AVLiveQuery!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        classifyTableView.frame.size.height = tableviewContainer.frame.height
        bakeTableView.frame.size.height = tableviewContainer.frame.height
        
        classifyTableView.isScrollEnabled = false
        
        bake = theShops["1"] as! [String : Any]
        bakes = bake["bakes"] as! [String: Any]

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
            cell.classLabel.text = "分类"
            return cell
        case 1:
            let cell = bakeTableView.dequeueReusableCell(withIdentifier: "shopBuyBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopBuyBakeTableCell
            cell.selectionStyle = .none
            
            let bakee = bakes["\(buyBake[indexPath.row])"] as! [String: Any]
            
            let bakeName = bakee["name"] as! String
            let price = bakee["price"] as! Double
            let left = bakee["amount"] as! Int
            // let star = bakee["star"] as! Double
            
            cell.bakeImage.image = UIImage(named: bakeName)
            cell.nameLabel.text = bakeName
            cell.priceLabel.text = "¥\(price)"
            cell.leftLabel.text = "剩余 \(left)"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView.tag {
        case 0:
            count = 1
        case 1:
            count = bakes.count
            // count the bakes whose amount is larger than 0
            for bakee in bakes {
                let bakeInfo = bakee.value as! [String: Any]
                
                if (bakeInfo["amount"] as! Int) <= 0 {
                    count -= 1
                } else {
                    buyBake.append(Int(bakee.key)!)
                }
            }
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
                printit(any: "subscribed")
            } else {
                // TODO: - handle error
                printit(any: error.localizedDescription)
            }
        })
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        
    }


}
