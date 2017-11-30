//
//  ShopPreVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

class ShopPreVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var classifyTableView: ShopClassifyTableView!
    @IBOutlet weak var bakeTableView: ShopPreBakeTableView!
    @IBOutlet weak var helperView: UIView!

    var shopVC: ShopVC!
    var avshop: AVShop!
    var avtag: [String]!
    var avbakes: [AVBake]!
    var avbakesTag = [String: [AVBake]]()
    var avbakesSoldOut = [String: [AVBake]]()
    var avbakesDetailDict = [AVBake: [AVBakeDetail]]()
    
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
        buyQuery.whereKey("stock", equalTo: 1) // only for pre-order
        let bothQuery = AVBake.query()
        bothQuery.whereKey("stock", equalTo: 2) // for buy or pre-order
        let orQuery = AVQuery.orQuery(withSubqueries: [buyQuery, bothQuery])
        let query = AVQuery.andQuery(withSubqueries: [shopQuery, orQuery])
        query.includeKey("image")
        query.includeKey("defaultBake")
        query.includeKey("defaultBake.bake")
        query.includeKey("defaultBake.image")
        query.includeKey("defaultBake.attributes")
        query.includeKey("defaultBake.attributes.attribute0")
        query.includeKey("defaultBake.attributes.attribute1")
        query.includeKey("defaultBake.attributes.attribute2")
        query.includeKey("shop")
        query.addAscendingOrder("priority")
        query.findObjectsInBackground({
            objects, error in
            if error == nil {
                self.avbakes = objects as? [AVBake]
                if let _ = self.avbakes {
                    self.assignBakeTag()
                } else {
                    self.shopVC.showLoadFailedView()
                }
            } else {
                self.shopVC.stopIndicatorViewAni()
                self.shopVC.showLoadFailedView()
                printit(any: "shop pre vc \(error!.localizedDescription)")
            }
        })
    }

    class func instantiateFromStoryboard() -> ShopPreVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! ShopPreVC
    }
    
    func assignBakeTag() {
        // assign bakes in their tags and take "sold out" as a new array
        var bakeDetailsCount = 0
        for bake in self.avbakes {
            guard let bakeAttr = bake.attributes else { break }
            guard let tag = bake.tag else { break }
            if bakeAttr.count == 0 {
                guard let bakeDetail = bake.defaultBake else { break }
                guard bakeDetail.status else { break }
                let id = bakeDetail.objectId!
                if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: id) {
                    assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
                }
                if bakeDetail.amount == 0 {
                    if let _ = self.avbakesSoldOut[tag] {
                        self.avbakesSoldOut[tag]!.append(bake)
                    } else {
                        self.avbakesSoldOut[tag] = [bake]
                    }
                } else {
                    if let _ = self.avbakesTag[tag] {
                        self.avbakesTag[tag]!.append(bake)
                    } else {
                        self.avbakesTag[tag] = [bake]
                    }
                }
            } else {
                if let bakeDetails = avbakesDetailDict[bake] {
                    assignAVBakeDetail(tag: tag, bake: bake, bakeDetails: bakeDetails)
                } else {
                    bakeDetailsCount += 1
                    let query = AVBakeDetail.query()
                    query.includeKey("bake")
                    query.includeKey("attributes")
                    query.includeKey("attributes.attribute0")
                    query.includeKey("attributes.attribute1")
                    query.includeKey("attributes.attribute2")
                    query.whereKey("bake", equalTo: bake)
                    query.findObjectsInBackground({
                        objects, error in
                        if let error = error {
                            self.shopVC.stopIndicatorViewAni()
                            self.shopVC.showLoadFailedView()
                            printit(any: "shop buy vc \(error.localizedDescription)")
                        } else {
                            self.avbakesDetailDict[bake] = objects as? [AVBakeDetail]
                            if let bakeDetails = self.avbakesDetailDict[bake] {
                                self.assignAVBakeDetail(tag: tag, bake: bake, bakeDetails: bakeDetails)
                                bakeDetailsCount -= 1
                                if bakeDetailsCount == 0 {
                                    self.assignTags()
                                }
                                self.shopVC.setShopBagState()
                            } else {
                                self.shopVC.showLoadFailedView()
                            }
                        }
                    })
                }
            }
        }
        if bakeDetailsCount == 0 {
            assignTags()
        }
        self.shopVC.setShopBagState()
    }
    
    func assignTags() {
        // append sold out bakes to the end of all bakes
        for (n, tag) in avtag.enumerated() {
            let soldOutBakes = avbakesSoldOut[tag] ?? []
            if let _ = avbakesTag[tag] {
                for bake in soldOutBakes {
                    if avbakesTag[tag]!.contains(bake) {
                        avbakesTag[tag]!.remove(at: avbakesTag[tag]!.index(of: bake)!)
                    }
                }
                avbakesTag[tag]!.append(contentsOf: soldOutBakes)
            } else {
                avbakesTag[tag] = soldOutBakes
            }
            if let bakes = avbakesTag[tag] {
                if bakes.count == 0 {
                    avtag[n] = ""
                }
            } else {
                avtag[n] = ""
            }
        }
        avtag = avtag.filter({ return $0 != "" })
        if avtag.count > 0 {
            self.shopVC.stopIndicatorViewAni()
            self.classifyTableView.reloadData()
            self.bakeTableView.reloadData()
        } else {
            self.shopVC.stopIndicatorViewAni()
            self.shopVC.showLoadFailedView()
        }
    }
    
    func assignAVBakeDetail(tag: String, bake: AVBake, bakeDetails: [AVBakeDetail]) {
        var totalAmount = 0
        for bakeDetail in bakeDetails {
            guard bakeDetail.status else { break }
            guard let amount = bakeDetail.amount as? Int else { break }
            totalAmount += amount
            let id = bakeDetail.objectId!
            if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: id) {
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
            }
        }
        if totalAmount == 0 {
            if let _ = self.avbakesSoldOut[tag] {
                self.avbakesSoldOut[tag]!.append(bake)
            } else {
                self.avbakesSoldOut[tag] = [bake]
            }
        } else {
            if let _ = self.avbakesTag[tag] {
                self.avbakesTag[tag]!.append(bake)
            } else {
                self.avbakesTag[tag] = [bake]
            }
        }
    }

    func assignAVBakeOrder(bakeRealm: BakePreOrderRealm?, bake: AVBakeDetail) {
        let bakePre = AVBakePre()
        bakePre.bake = bake
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
            guard let bakeDetail = bake.defaultBake else { break }
            let id = bakeDetail.objectId!
            if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: id) {
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
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
    
    func addBakeToRealm(_ bakeDetail: AVBakeDetail, amount: Int = 1) {
        guard let bake = bakeDetail.bake else { return }
        let bakeRealm = BakePreOrderRealm()
        bakeRealm.id = bakeDetail.objectId!
        bakeRealm.amount = amount
        bakeRealm.price = bakeDetail.price as! Double
        bakeRealm.name = bake.name!
        bakeRealm.tag = bake.tag!
        bakeRealm.shopID = avshop.objectId!
        RealmHelper.addOneBake(bakeRealm)
    }
    
    func oneMoreBake(_ cell: ShopPreBakeTableCell) {
        guard let bake = cell.bake else { return }
        guard let bakeDetail = bake.defaultBake else { return }
        if oneMoreBake(bake: bake, bakeDetail: bakeDetail, amountLabel: cell.amountLabel) {
            setShopCellFromNoneToOne(cell)
        }
    }
    
    func oneMoreBake(bake: AVBake, bakeDetail: AVBakeDetail, amountLabel: UILabel) -> Bool {
        if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: bakeDetail.objectId!) {
            RealmHelper.addOneMoreBake(bakeRealm)
            amountLabel.text = "\(bakeRealm.amount)"
            assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
            return false
        } else {
            addBakeToRealm(bakeDetail)
            amountLabel.text = "1"
            assignAVBakeOrder(bakeRealm: nil, bake: bakeDetail)
            return true
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
        guard let bakeDetail = bake.defaultBake else { return }
        if minusOneBake(bake: bake, bakeDetail: bakeDetail, amountLabel: cell.amountLabel) {
            setShopCellToNone(cell)
        }
    }
    
    func minusOneBake(bake: AVBake, bakeDetail: AVBakeDetail, amountLabel: UILabel) -> Bool {
        if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: bakeDetail.objectId!) {
            if RealmHelper.minueOneBake(bakeRealm) {
                avbakesPre[bakeDetail.objectId!] = nil
                return true
            } else {
                let amount = bakeRealm.amount
                amountLabel.text = "\(amount)"
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
            }
        }
        return false
    }
    
    func setShopCellToNone(_ cell: ShopPreBakeTableCell) {
        cell.amountLabel.isHidden = true
        cell.minusOneBtn.isHidden = true
    }
    
    
    // specification selection
    func specBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopPreBakeTableCell else { return }
        guard let bake = cell.bake else { return }
        guard let bakeDetails = avbakesDetailDict[bake] else { return }
        if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
        shopVC.showBakeSpecView(bake: bake, bakeDetails: bakeDetails)
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
            count = avbakes == nil ? 0 : (avbakesTag[avtag[section]]?.count ?? 0)
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
            let count = RealmHelper.retrieveBakesPreOrderCount(by: tag, avbakesPre: avbakesPre)
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
            
            let bake = avbakesTag[avtag[section]]![indexPath.row]
            guard let bakeDetail = bake.defaultBake else { return UITableViewCell() }
            
            guard let bakeName = bake.name else { return UITableViewCell() }
            guard let priceRange = bake.priceRange else { return UITableViewCell() }
            var price = ""
            if priceRange.count == 1 {
                price += "\(priceRange[0])"
            } else if priceRange.count == 2 {
                price += "\(priceRange[0])-\(priceRange[1])"
            } else {
                price += "0"
            }

            let monthly = 100 // TODO
            let bakePreOrder = RealmHelper.retrieveOneBakePreOrder(by: bake.objectId!)
            let amountPreOrder = bakePreOrder?.amount ?? 0
            
            if bake.image == nil { printit(any: "\n\n\n\n\n\n\(bake.name ?? "nil")\n\n\n\n\n\n") }
            
            cell.bake = bake
            cell.bakeImage.contentMode = .scaleAspectFill
            cell.bakeImage.sd_setImage(with: URL(string: bake.image?.url ?? ""))
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
            if let bakeAttr = bake.attributes {
                if bakeAttr.count == 0 {
                    cell.specBtn.isHidden = true
                    let amount = bakeDetail.amount as? Int ?? 10
                    if amount == 0 {
                        cell.amountLabel.isHidden = true
                        cell.minusOneBtn.isHidden = true
                        cell.oneMoreBtn.isHidden = true
                        cell.soldOutLabel.isHidden = false
                    } else {
                        cell.oneMoreBtn.addTarget(self, action: #selector(ShopPreVC.oneMoreBtnPressed(_:)), for: .touchUpInside)
                        cell.minusOneBtn.addTarget(self, action: #selector(ShopPreVC.minusOneBtnPressed(_:)), for: .touchUpInside)
                        cell.soldOutLabel.isHidden = true
                    }
                } else {
                    let amount = bakeDetail.amount as? Int ?? 10
                    cell.amountLabel.isHidden = true
                    cell.minusOneBtn.isHidden = true
                    cell.oneMoreBtn.isHidden = true
                    cell.soldOutLabel.isHidden = true
                    cell.specBtn.isHidden = false
                    cell.specBtn.makeRoundCorder()
                    cell.specBtn.addTarget(self, action: #selector(ShopPreVC.specBtnPressed(_:)), for: .touchUpInside)
                }
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
        let row = indexPath.row
        switch tableView.tag {
        case 0:
            if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
            tappedAtTagTableview = true
            if let bakes = avbakesTag[avtag[row]] {
                if bakes.count > 0 {
                    bakeTableView.selectRow(at: IndexPath(row: 0, section: row), animated: true, scrollPosition: .top)
                }
            }
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
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    


}
