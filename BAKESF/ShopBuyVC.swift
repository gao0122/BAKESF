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
    
    var shopVC: ShopVC!
    let cartBarHeight: CGFloat = 50
    var shopView: UIView!
    var originShopY: CGFloat!
    var buyBake = [Int]()
    var avtag: [String]!
    var avshop: AVShop!
    var avbakes: [AVBake]!
    var avbakesTag = [String: [AVBake]]()
    var bakeLiveQuery: AVLiveQuery!
    
    var tappedAtTagTableview = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        avtag = avshop.tags!
        classifyTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        classifyTableView.isUserInteractionEnabled = false

        let shopQuery = AVBake.query()
        shopQuery.whereKey("Shop", equalTo: avshop)
        let buyQuery = AVBake.query()
        buyQuery.whereKey("stock", equalTo: 0) // only for buy
        let bothQuery = AVBake.query()
        bothQuery.whereKey("stock", equalTo: 2) // for buy or book
        let orQuery = AVQuery.orQuery(withSubqueries: [buyQuery, bothQuery])
        let query = AVQuery.andQuery(withSubqueries: [shopQuery, orQuery])
        query.includeKey("image")
        query.addAscendingOrder("priority")
        query.findObjectsInBackground({
            objects, error in
            if error == nil {
                self.avbakes = objects as! [AVBake]
                self.assignBakeTag()
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
    
    func assignBakeTag() {
        for bake in self.avbakes {
            if let _ = self.avbakesTag[bake.tag!] {
                self.avbakesTag[bake.tag!]!.append(bake)
            } else {
                self.avbakesTag[bake.tag!] = [bake]
            }
        }
    }
    
    func oneMoreBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBuyBakeTableCell else { return }
        guard let amountLabelText = shopVC.totalAmountLabel.text else { return }
        if amountLabelText == "" {
            shopVC.totalAmountLabel.text = "1"
            shopVC.checkBtn.setTitle("结算", for: .normal)
            shopVC.checkBtn.backgroundColor = .appleGreen
            shopVC.emptyBagLabel.alpha = 0
            shopVC.rightLowestFeeLabel.alpha = 0
            shopVC.rightDistributionFeeLabel.alpha = 0
            shopVC.distributionFeeLabel.alpha = 1
            shopVC.totalFeeLabel.alpha = 1
        } else {
            shopVC.totalAmountLabel.text = "\(Int(amountLabelText)! + 1)"
        }
        
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
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            cell.backgroundColor = UIColor(hex: 0xEFEFEF)
            cell.layer.cornerRadius = 2
            cell.classLabel.textColor = .bkBlack
            cell.classLabel.text = avtag[indexPath.row]
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
                printit(any: "\n\n\n\n\n\n\(bakee.name!)\n\n\n\n\n\n")
            }
            cell.bakeImage.sd_setImage(with: URL(string: bakee.image?.url ?? ""))
            cell.bakeImage.clipsToBounds = true
            cell.bakeImage.layer.cornerRadius = 3
            cell.nameLabel.text = bakeName
            cell.priceLabel.text = "¥\(price)"
            cell.leftLabel.text = "剩余 \(left)"
            cell.oneMoreBtn.addTarget(self, action: #selector(ShopBuyVC.oneMoreBtnPressed(_:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView.tag {
        case 1:
            let tableFooterView = UIView()
            tableFooterView.frame.size.width = bakeTableView.frame.width
            tableFooterView.frame.size.height = cartBarHeight
            return tableFooterView
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch tableView.tag {
        case 1:
            return cartBarHeight
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView.tag {
        case 0:
            count = avtag.count
        case 1:
            count = avbakes == nil ? 0 : avbakes.count
        default:
            break
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:
            let cell = tableView.cellForRow(at: indexPath) as! ShopClassifyTableCell
            let tag = cell.classLabel.text!
            guard let tagIndex = avtag.index(of: tag) else { return }
            var row = 0
            for i in 0..<tagIndex {
                row += avbakesTag[avtag[i]]?.count ?? 0
            }
            tappedAtTagTableview = true
            bakeTableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .top)
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! ShopBuyBakeTableCell
        default:
            break
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tappedAtTagTableview = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag != 1 { return }
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        } else {
            scrollView.isScrollEnabled = true
        }
        
        // determine category and bake
        if tappedAtTagTableview { return }
        guard let indexPath = bakeTableView.indexPathsForVisibleRows?.first else { return }
        guard let cell = bakeTableView.cellForRow(at: indexPath) as? ShopBuyBakeTableCell else { return }
        let tag = cell.bake.tag!
        guard let tagIndex = avtag.index(of: tag) else { return }
        classifyTableView.selectRow(at: IndexPath(row: tagIndex, section: 0), animated: true, scrollPosition: .none)
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
            } else {
                // TODO: - handle error
                printit(any: error.localizedDescription)
            }
        })
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        
    }

}
