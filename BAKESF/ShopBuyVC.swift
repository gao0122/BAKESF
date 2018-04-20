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
    @IBOutlet weak var helperView: UIView!
    
    var shopVC: ShopVC!
    var avshop: AVShop!
    var avtag: [String]!
    var avbakes: [AVBake]!
    var avbakesTag = [String: [AVBake]]()
    var avbakesSoldOut = [String: [AVBake]]()
    var avbakesDetailDict = [AVBake: [AVBakeDetail]]()
    
    var avbakesIn = [String: AVBakeIn]()
    var tappedAtTagTableview = false
    var assignedSoldOutTags = false
    
    var bakeLiveQuery: AVLiveQuery!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bringSubview(toFront: helperView)
        helperView.isHidden = true
        avtag = avshop.tags ?? []
        classifyTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        classifyTableView.rowHeight = UITableViewAutomaticDimension
        classifyTableView.estimatedRowHeight = 58

        bakeTableView.tableFooterView = UIView.tableFooterView(height: bagBarHeight)
        
        loadAVBakes()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func loadAVBakes() {
        let shopQuery = AVBake.query()
        shopQuery.whereKey("shop", equalTo: avshop)
        let buyQuery = AVBake.query()
        buyQuery.whereKey("stock", equalTo: 0) // only for buy
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
        self.shopVC.startIndicatorViewAni()
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
                printit(any: "shop buy vc \(error!.localizedDescription)")
            }
        })
    }

    class func instantiateFromStoryboard() -> ShopBuyVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! ShopBuyVC
    }
    
    func checkSearchingBake() {
        guard let bake = shopVC.searchingBake else { return }
        guard let tag = bake.tag else { return }
        guard let bakes = avbakesTag[tag] else { return }
        guard let row: Int = bakes.index(of: bake) else { return }
        guard let section: Int = avtag.index(of: tag) else { return }
        let indexPath = IndexPath(row: row, section: section)
        guard shopVC.pagingMenuController.currentPage == 0 else { return }
        shopVC.animateMenu(self)
        bakeTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    func assignBakeTag() {
        // assign bakes in their tags and take "sold out" as a new array
        var bakeDetailsCount = 0
        assignedSoldOutTags = false
        for bake in self.avbakes {
            guard let bakeAttr = bake.attributes else { continue }
            guard let tag = bake.tag else { continue }
            if bakeAttr.count == 0 {
                guard let bakeDetail = bake.defaultBake else { continue }
                guard bakeDetail.status else { continue }
                guard let id = bakeDetail.objectId else { continue }
                if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: id) {
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
                                    self.assignSoldOutTags()
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
            assignSoldOutTags()
        }
        self.shopVC.setShopBagState()
    }
    
    func assignSoldOutTags() {
        guard !assignedSoldOutTags else { return }
        assignedSoldOutTags = true
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
            // filter bakes which are sold out or not valid
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
            self.shopVC.hideLoadFailedView()
            self.classifyTableView.reloadData()
            self.bakeTableView.reloadData()
            self.checkSearchingBake()
        } else {
            self.shopVC.stopIndicatorViewAni()
            self.shopVC.showLoadFailedView(with: "烘焙师暂时还没有上架商品")
        }
    }
    
    func assignAVBakeDetail(tag: String, bake: AVBake, bakeDetails: [AVBakeDetail]) {
        var totalAmount = 0
        for bakeDetail in bakeDetails {
            guard bakeDetail.status else { continue }
            guard let amount = bakeDetail.amount as? Int else { continue }
            totalAmount += amount
            let id = bakeDetail.objectId!
            if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: id) {
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
    
    func assignAVBakeOrder(bakeRealm: BakeInBagRealm?, bake: AVBakeDetail) {
        let bakeIn = AVBakeIn()
        bakeIn.bake = bake
        if let bakeRealm = bakeRealm {
            bakeIn.amount = bakeRealm.amount as NSNumber
        } else {
            bakeIn.amount = 1
        }
        avbakesIn[bake.objectId!] = bakeIn
    }

    func reloadAVBakeOrder() {
        if avbakes == nil { return }
        for avbake in avbakes {
            guard let bake = avbake.defaultBake else { continue }
            let id = bake.objectId!
            if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: id) {
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bake)
            }
        }
    }
    
    // one more button pressed
    func oneMoreBtnPressed(_ sender: UIButton) {
        if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
        guard let cell = sender.superview?.superview as? ShopBuyBakeTableCell else { return }
        oneMoreBake(cell)
        shopVC.setShopBagState()
        classifyTableView.reloadData()
    }
    
    func setShopCellFromNoneToOne(_ cell: ShopBuyBakeTableCell, amount: Int = 1) {
        cell.amountLabel.isHidden = false
        cell.minusOneBtn.isHidden = false
        cell.amountLabel.text = "\(amount)"
    }
    
    func addBakeToRealm(_ bakeDetail: AVBakeDetail, amount: Int = 1) {
        guard let bake = bakeDetail.bake else { return }
        let bakeRealm = BakeInBagRealm()
        bakeRealm.id = bakeDetail.objectId!
        bakeRealm.amount = amount
        bakeRealm.price = bakeDetail.price as! Double
        bakeRealm.name = bake.name!
        bakeRealm.tag = bake.tag!
        bakeRealm.shopID = avshop.objectId!
        RealmHelper.addOneBake(bakeRealm)
    }
    
    func oneMoreBake(_ cell: ShopBuyBakeTableCell) {
        guard let bake = cell.bake else { return }
        guard let bakeDetail = bake.defaultBake else { return }
        if oneMoreBake(bake: bake, bakeDetail: bakeDetail, amountLabel: cell.amountLabel) {
            setShopCellFromNoneToOne(cell)
        }
    }
    
    func oneMoreBake(_ cell: UITableViewCell? = nil, bake: AVBake, bakeDetail: AVBakeDetail, amountLabel: UILabel) -> Bool {
        if let cell = cell as? ShopBuyBakeTableCell {
            cell.bakesCount += 1
            resetSpecBtnText(cell)
        }
        if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: bakeDetail.objectId!) {
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
        guard let cell = sender.superview?.superview as? ShopBuyBakeTableCell else { return }
        minusOneBake(cell)
        shopVC.setShopBagState()
        classifyTableView.reloadData()
    }
    
    func minusOneBake(_ cell: ShopBuyBakeTableCell) {
        guard let bake = cell.bake else { return }
        guard let bakeDetail = bake.defaultBake else { return }
        if minusOneBake(bake: bake, bakeDetail: bakeDetail, amountLabel: cell.amountLabel) {
            setShopCellToNone(cell)
        }
    }
    
    func minusOneBake(_ cell: UITableViewCell? = nil, bake: AVBake, bakeDetail: AVBakeDetail, amountLabel: UILabel) -> Bool {
        if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: bakeDetail.objectId!) {
            if let cell = cell as? ShopBuyBakeTableCell {
                cell.bakesCount -= 1
                resetSpecBtnText(cell)
            }
            if RealmHelper.minueOneBake(bakeRealm) {
                avbakesIn[bakeDetail.objectId!] = nil
                return true
            } else {
                let amount = bakeRealm.amount
                amountLabel.text = "\(amount)"
                assignAVBakeOrder(bakeRealm: bakeRealm, bake: bakeDetail)
            }
        }
        return false
    }
    
    func setShopCellToNone(_ cell: ShopBuyBakeTableCell) {
        cell.amountLabel.isHidden = true
        cell.minusOneBtn.isHidden = true
    }

    
    // specification selection
    func specBtnPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ShopBuyBakeTableCell else { return }
        guard let bake = cell.bake else { return }
        guard let bakeDetails = avbakesDetailDict[bake] else { return }
        if shopVC.menuAniState == .collapsed { shopVC.animateMenu(state: shopVC.menuAniState) }
        shopVC.showBakeSpecView(cell, bake: bake, bakeDetails: bakeDetails)
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
            let count = RealmHelper.retrieveBakesInBagCount(by: tag, avbakesIn: avbakesIn)
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
            let cell = bakeTableView.dequeueReusableCell(withIdentifier: "shopBuyBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopBuyBakeTableCell
            cell.selectionStyle = .none
            
            let bake = avbakesTag[avtag[section]]![indexPath.row]
            
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

            
            
            if bake.image == nil { printit(any: "\n\n\n\n\n\n\(bake.name!)\n\n\n\n\n\n") }

            cell.bake = bake
            if bake == shopVC.searchingBake {
                cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.0448)
            } else {
                cell.backgroundColor = UIColor.clear
            }
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
            cell.soldOutLabel.isHidden = false
            if let bakeAttr = bake.attributes {
                if bakeAttr.count == 0 {
                    guard let bakeDetail = bake.defaultBake else { return UITableViewCell() }
                    let bakeInBag = RealmHelper.retrieveOneBakeInBag(by: bakeDetail.objectId!)
                    let amountInBag = bakeInBag?.amount ?? 0
                    if amountInBag == 0 {
                        cell.amountLabel.isHidden = true
                        cell.minusOneBtn.isHidden = true
                    } else {
                        cell.amountLabel.text = "\(amountInBag)"
                    }
                    cell.specBtn.isHidden = true
                    let amount = bakeDetail.amount as? Int ?? 10
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
                } else {
                    var amountInBag = 0
                    if let avbakesDetail = avbakesDetailDict[bake] {
                        for bakeDetail in avbakesDetail {
                            amountInBag += (RealmHelper.retrieveOneBakeInBag(by: bakeDetail.objectId!)?.amount ?? 0)
                        }
                        cell.bakesCount = amountInBag
                        resetSpecBtnText(cell)
                        cell.amountLabel.isHidden = true
                        cell.minusOneBtn.isHidden = true
                        cell.oneMoreBtn.isHidden = true
                        cell.soldOutLabel.isHidden = true
                        cell.specBtn.isHidden = false
                        cell.specBtn.makeRoundCorder()
                        cell.specBtn.addTarget(self, action: #selector(ShopBuyVC.specBtnPressed(_:)), for: .touchUpInside)
                    }
                }
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func resetSpecBtnText(_ cell: ShopBuyBakeTableCell) {
        let amount = cell.bakesCount
        if amount == 0 {
            cell.specBtn.setTitle("选规格", for: .normal)
        } else {
            var amountText = "\(amount)"
            if amount > 99 { amountText = "99+" }
            cell.specBtn.setTitle("已选 \(amountText)", for: .normal)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView.tag == 1 ? avtag[section] : nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView.tag {
        case 1:
            if section == avtag.count - 1 { 
                // footer view of the last section
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
        //return tableView.tag == 1 && section == avtag.count - 1 ? bagBarHeight : 0
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
            if shopVC.menuAniState == .collapsed {
                shopVC.animateMenu(state: shopVC.menuAniState)
            }
            tappedAtTagTableview = true
            if let bakes = avbakesTag[avtag[row]] {
                if bakes.count > 0 {
                    bakeTableView.selectRow(at: IndexPath(row: 0, section: row), animated: true, scrollPosition: .top)
                }
            }
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as! ShopBuyBakeTableCell
            // TODO: - bake selection
            let avbake = cell.bake
            
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
    
    // live queries
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        
    }

}
