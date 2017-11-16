//
//  ShopPreVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

@available(iOS 10.0, *)
class ShopPreVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var classifyTableView: ShopClassifyTableView!
    @IBOutlet weak var bakeTableView: ShopPreBakeTableView!
    @IBOutlet weak var helperView: UIView!

    var shopVC: ShopVC!
    var avshop: AVShop!
    var avtag: [String]!
    var avbakes: [AVBake]!
    var avbakesTag = [String: [AVBake]]()
    
    var avbakesPre = [String: AVBakePre]()
    var tappedAtTagTableview = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.bringSubview(toFront: helperView)
        helperView.isHidden = true
        avtag = avshop.tags!
        classifyTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        classifyTableView.rowHeight = UITableViewAutomaticDimension
        classifyTableView.estimatedRowHeight = 58

        loadAVBakes()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func loadAVBakes() {
        let shopQuery = AVBake.query()
        shopQuery.whereKey("shop", equalTo: avshop)
        let buyQuery = AVBake.query()
        buyQuery.whereKey("stock", equalTo: 1) // only for buy
        let bothQuery = AVBake.query()
        bothQuery.whereKey("stock", equalTo: 2) // for buy or book
        let orQuery = AVQuery.orQuery(withSubqueries: [buyQuery, bothQuery])
        let query = AVQuery.andQuery(withSubqueries: [shopQuery, orQuery])
        query.includeKey("image")
        query.addAscendingOrder("priority")
        query.findObjectsInBackground({
            objects, error in
            if error == nil {
                self.avbakes = objects as? [AVBake]
                if let _ = self.avbakes {
                    self.assignBakeTag()
                    self.shopVC.stopIndicatorViewAni()
                } else {
                    self.shopVC.showLoadFailedView()
                }
            } else {
                self.shopVC.stopIndicatorViewAni()
                printit(any: "shop buy vc \(error!.localizedDescription)")
            }
        })
    }

    class func instantiateFromStoryboard() -> ShopPreVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! ShopPreVC
    }
    
    func assignBakeTag() {
        // assign bakes in their tags and take "sold out" as a new array
        for bake in self.avbakes {
            let id = bake.objectId!
            let tag = bake.tag!
            if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: id) {
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bake)
            }
            if let _ = self.avbakesTag[tag] {
                self.avbakesTag[tag]!.append(bake)
            } else {
                self.avbakesTag[tag] = [bake]
            }
        }
        self.bakeTableView.reloadData()
    }

    func assignAVBakeOrder(bakeRealm: BakePreOrderRealm?, bake: AVBake) {
        let bakePre = AVBakePre()
        bakePre.bakee = bake
        if let bakeRealm = bakeRealm {
            bakePre.amount = bakeRealm.amount as NSNumber
        } else {
            bakePre.amount = 1
        }
        avbakesPre[bake.objectId!] = bakePre
    }
    
    func reloadAVBakeOrder() {
        if avbakes == nil { return }
        for bake in avbakes {
            let id = bake.objectId!
            if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: id) {
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bake)
            }
        }
    }

    // one more button pressed
    func oneMoreBtnPressed(_ sender: UIButton) {
        if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
        guard let cell = sender.superview?.superview as? ShopPreBakeTableCell else { return }
        oneMoreBake(cell)
        shopVC.setShopBagState()
        classifyTableView.reloadData()
    }
        
    func setShopCellFromNoneToOne(_ cell: ShopPreBakeTableCell, amount: Int = 1) {
        cell.amountLabel.isHidden = false
        cell.minusOneBtn.isHidden = false
        cell.amountLabel.text = "\(amount)"
    }
    
    func addBakeToRealm(_ bake: AVBake, amount: Int = 1) {
        let bakeRealm = BakePreOrderRealm()
        bakeRealm.id = bake.objectId!
        bakeRealm.amount = amount
        bakeRealm.price = bake.price as! Double
        bakeRealm.name = bake.name!
        bakeRealm.tag = bake.tag!
        bakeRealm.shopID = avshop.objectId!
        RealmHelper.addOneBake(bakeRealm)
    }
    
    func oneMoreBake(_ cell: ShopPreBakeTableCell) {
        guard let bake = cell.bake else { return }
        if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: bake.objectId!) {
            RealmHelper.addOneMoreBake(bakeRealm)
            cell.amountLabel.text = "\(bakeRealm.amount)"
            assignAVBakeOrder(bakeRealm: bakeRealm, bake: bake)
        } else {
            addBakeToRealm(bake)
            setShopCellFromNoneToOne(cell)
            cell.amountLabel.text = "1"
            assignAVBakeOrder(bakeRealm: nil, bake: bake)
        }
    }
    
    // minus one button pressed
    func minusOneBtnPressed(_ sender: UIButton) {
        if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
        guard let cell = sender.superview?.superview as? ShopPreBakeTableCell else { return }
        minusOneBake(cell)
        shopVC.setShopBagState()
        classifyTableView.reloadData()
    }
    
    func minusOneBake(_ cell: ShopPreBakeTableCell) {
        guard let bake = cell.bake else { return }
        if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: bake.objectId!) {
            if RealmHelper.minueOneBake(bakeRealm) {
                setShopCellToNone(cell)
                avbakesPre[bake.objectId!] = nil
                printit(avbakesPre)
            } else {
                let amount = bakeRealm.amount
                cell.amountLabel.text = "\(amount)"
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bake)
            }
        }
    }
    
    func setShopCellToNone(_ cell: ShopPreBakeTableCell) {
        cell.amountLabel.isHidden = true
        cell.minusOneBtn.isHidden = true
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0: // classify table
            return 1
        case 1: // bake table
            return avtag.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView.tag {
        case 0:
            count = avtag.count
        case 1:
            count = avbakes == nil ? 0 : avbakesTag[avtag[section]]!.count
        default:
            break
        }
        return count
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
            let tag = avtag[indexPath.row]
            cell.classLabel.textColor = .bkBlack
            cell.classLabel.text = tag
            let count = RealmHelper.retrieveBakesPreOrderCount(by: tag)
            if count > 0 {
                if count > 999 {
                    cell.amountLabel.text = "999+"
                } else {
                    cell.amountLabel.text = "\(count)"
                }
                let height = cell.amountLabel.frame.size.height
                cell.amountLabel.layer.cornerRadius = height / 2
                cell.amountLabel.layer.masksToBounds = true
                cell.amountLabel.sizeToFit()
                var width = cell.amountLabel.frame.size.width + 7
                if width < height {
                    width = height
                }
                cell.amountLabelHeight.constant = height
                cell.amountLabelWidth.constant = width
                cell.amountLabel.updateConstraintsIfNeeded()
                cell.amountLabel.isHidden = false
            } else {
                cell.amountLabel.isHidden = true
            }
            return cell
        case 1:
            let section = indexPath.section
            let cell = bakeTableView.dequeueReusableCell(withIdentifier: "shopPreBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopPreBakeTableCell
            cell.selectionStyle = .none
            
            let bakee = avbakesTag[avtag[section]]![indexPath.row]
            
            let bakeName = bakee.name!
            let price = bakee.price!
            let monthly = bakee.monthly as! Int
            let amount = bakee.amountPreLimit as! Int
            let bakePreOrder = RealmHelper.retrieveOneBakePreOrder(by: bakee.objectId!)
            let amountPreOrder = bakePreOrder?.amount ?? 0
            
            if bakee.image == nil { printit(any: "\n\n\n\n\n\n\(bakee.name!)\n\n\n\n\n\n") }
            
            cell.bake = bakee
            cell.bakeImage.contentMode = .scaleAspectFill
            cell.bakeImage.sd_setImage(with: URL(string: bakee.image?.url ?? ""))
            cell.bakeImage.clipsToBounds = true
            cell.bakeImage.layer.cornerRadius = 3
            cell.nameLabel.text = bakeName
            cell.priceLabel.text = "¥\(price)"
            cell.monthlyLabel.text = "月售 \(monthly)"
            cell.amountLabel.isHidden = false
            cell.minusOneBtn.isHidden = false
            cell.oneMoreBtn.isHidden = false
            if amountPreOrder == 0 {
                cell.amountLabel.isHidden = true
                cell.minusOneBtn.isHidden = true
            } else {
                cell.amountLabel.text = "\(amountPreOrder)"
            }
            if amount == 0 {
                cell.amountLabel.isHidden = true
                cell.minusOneBtn.isHidden = true
                cell.oneMoreBtn.isHidden = true
                cell.soldOutLabel.isHidden = false
            } else {
                cell.oneMoreBtn.addTarget(self, action: #selector(ShopBuyVC.oneMoreBtnPressed(_:)), for: .touchUpInside)
                cell.minusOneBtn.addTarget(self, action: #selector(ShopBuyVC.minusOneBtnPressed(_:)), for: .touchUpInside)
                cell.soldOutLabel.isHidden = true
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView.tag == 1 ? avtag[section] : nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView.tag {
        case 1:
            if section == avtag.count - 1 {
                let tableFooterView = UIView()
                tableFooterView.frame.size.width = bakeTableView.frame.width
                tableFooterView.frame.size.height = bagBarHeight
                return tableFooterView
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.tag == 1 && section == avtag.count - 1 ? bagBarHeight : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch tableView.tag {
        case 1:
            return 28
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:
            if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
            tappedAtTagTableview = true
            bakeTableView.selectRow(at: IndexPath(row: 0, section: indexPath.row), animated: true, scrollPosition: .top)
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! ShopPreBakeTableCell
            // TODO: - bake selection
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
            bakeTableView.visibleCells.forEach { $0.isUserInteractionEnabled = true }
            bakeTableView.isScrollEnabled = true
        }
        
        // determine category and bake
        if tappedAtTagTableview { return }
        guard let indexPath = bakeTableView.indexPathsForVisibleRows?.first else { return }
        classifyTableView.selectRow(at: IndexPath(row: indexPath.section, section: 0), animated: true, scrollPosition: .none)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shopVC.shopView.frame.origin.y == shopVC.originShopY {
            bakeTableView.shouldScroll = false
        }
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
    

}
