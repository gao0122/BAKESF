//
//  SellerBuyVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class SellerBuyVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableviewContainer: UIView!
    @IBOutlet weak var classifyTableView: SellerClassifyTableView!
    @IBOutlet weak var bakeTableView: SellerBuyBakeTableView!
    
    var shopView: UIView!
    var originShopY: CGFloat!
    var bake: [String: Any]!
    var bakes: [String: Any]!
    var buyBake = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classifyTableView.frame.size.height = tableviewContainer.frame.height
        bakeTableView.frame.size.height = tableviewContainer.frame.height
        
        classifyTableView.isScrollEnabled = false
        
        bake = sellers["1"] as! [String : Any]
        bakes = bake["bakes"] as! [String: Any]

    }

    class func instantiateFromStoryboard() -> SellerBuyVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! SellerBuyVC
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
            let cell = classifyTableView.dequeueReusableCell(withIdentifier: "sellerClassifyTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! SellerClassifyTableCell
            cell.selectionStyle = .none
            cell.classLabel.text = "分类"
            return cell
        case 1:
            let cell = bakeTableView.dequeueReusableCell(withIdentifier: "sellerBuyBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! SellerBuyBakeTableCell
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
        printit(any: "end decelerating \(shopView.frame.origin.y)")
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

}
