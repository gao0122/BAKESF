//
//  ShopVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import AVOSCloud
import AVOSCloudLiveQuery

class ShopVC: UIViewController, UIGestureRecognizerDelegate {
    
    enum AniState {
        case expanded
        case collapsed
    }

    @IBOutlet weak var introBtn: UIButton!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var bgVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var cardBgImage: UIImageView!
    @IBOutlet weak var hpImage: UIImageView!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var stars: UIImageView!
    @IBOutlet weak var starsGray: UIImageView!
    @IBOutlet weak var commentNumberBtn: UIButton!
    @IBOutlet weak var starLabel: UIButton!
    @IBOutlet weak var broadcastLabel: UILabel!
    @IBOutlet weak var shopCardView: UIView!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var bagView: UIView!
    @IBOutlet weak var bagBar: UIView!
    @IBOutlet weak var bagBarBlurView: UIVisualEffectView!
    @IBOutlet weak var bagFocusBgView: UIView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var totalFeeLabel: UILabel!
    @IBOutlet weak var emptyBagLabel: UILabel!
    @IBOutlet weak var rightLowestFeeLabel: UILabel!
    @IBOutlet weak var rightDeliveryFeeLabel: UILabel!
    @IBOutlet weak var indicatorSuperView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loadFailedView: UIView!
    @IBOutlet weak var tryOneMoreTimeBtn: UIButton!
    @IBOutlet weak var takeItYourselfLabel: UILabel!
    @IBOutlet weak var deliveryByShopLabel: UILabel!
    @IBOutlet weak var bakeSpecView: UIView!
    @IBOutlet weak var bakeSpecImageView: UIImageView!
    @IBOutlet weak var bakeSpecOneMoreBtn: UIButton!
    @IBOutlet weak var bakeSpecMinusOneBtn: UIButton!
    @IBOutlet weak var bakeSpecAmountLabel: UILabel!
    @IBOutlet weak var bakeSpecNameLabel: UILabel!
    @IBOutlet weak var bakeSpecMainView: UIView!
    @IBOutlet weak var bakeSpecBgFocusView: UIView!
    @IBOutlet weak var bakeSpecAttributeView0: UIView!
    @IBOutlet weak var bakeSpecAttributeView1: UIView!
    @IBOutlet weak var bakeSpecAttributeView2: UIView!
    @IBOutlet weak var bakeSpecAttributeLabel0: UILabel!
    @IBOutlet weak var bakeSpecAttributeLabel1: UILabel!
    @IBOutlet weak var bakeSpecAttributeLabel2: UILabel!
    @IBOutlet weak var bakeSpecAttributeBtn0: UIButton!
    @IBOutlet weak var bakeSpecAttributeBtn1: UIButton!
    @IBOutlet weak var bakeSpecAttributeBtn2: UIButton!
    @IBOutlet weak var bakeSpecPriceLabel: UILabel!

    var shopBuyVC: ShopBuyVC!
    var shopPreVC: ShopPreVC!
    var shopBagVC: ShopBagEmbedVC!
    var shopCheckingVC: ShopCheckingVC!
    var pagingMenuController: ShopPagingVC!
    
    var avshop: AVShop!
    var avbaker: AVBaker?
    var userRealm: UserRealm!
    
    let topViewHeight: CGFloat = 64
    let menuAniDuration: TimeInterval = 0.48
    let nameLabelTransformY: CGFloat = 173
    let bagBarHeight: CGFloat = 50
    var startTranslationY: CGFloat = 0
    var startMenuState: AniState = .collapsed
    var addedPanRecognizer = false
    var originShopY: CGFloat!
    var originCardY: CGFloat!
    var originHeadphotoY: CGFloat!
    var originNameY: CGFloat!
    var shopViewStartY: CGFloat!
    var originBagBarY: CGFloat!
    var originBagViewY: CGFloat!
    var lastPanY: CGFloat!
    
    var menuAniState: AniState = .collapsed
    var runningMenuAnimators = [UIViewPropertyAnimator]()
    var menuProgressWhenInterrupted = [CGFloat]()

    var bagAniState: AniState = .collapsed
    
    let shopBagVCHeaderColor: Int = 0xFAFAFA
    
    let alwaysShowBag = true
    var lastPagingPage = 0
    
    let emptyBagText = "购物袋空空的"
    
    var shouldShowShopCheckingRN = false

    var bakeSpecButtons: [Int: [UIButton]]!
    var bakeSpecDict = [String: AVBakeDetail]()
    var currentSpecBtn0: UIButton?
    var currentSpecBtn1: UIButton?
    var currentSpecBtn2: UIButton?
    var currentSpecBake: AVBake?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        preInit()
        checkAVBaker()
        setPageMenu()
        shopInit()
        setShopBagState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.frame.origin.y = screenHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAVBaker()
        if shouldShowShopCheckingRN && avbaker != nil {
            performSegue(withIdentifier: "showShopCheckingSegue", sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setBackItemTitle(for: navigationItem)
        if let id = segue.identifier {
            switch id {
            case "shopBuyMenuSegue":
                guard let vc = segue.destination as? ShopPagingVC else { break }
                vc.view.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
            case "shopBuyBagSegue":
                guard let vc = segue.destination as? ShopBagEmbedVC else { break }
                self.shopBagVC = vc
                vc.shopVC = self
                vc.avshop = self.avshop
            case "showShopCheckingSegue":
                shouldShowShopCheckingRN = false
                guard let vc = segue.destination as? ShopCheckingVC else { break }
                vc.shopVC = self
                vc.avshop = self.avshop
                vc.isInBag = pagingMenuController.currentPage == 0
                navigationController?.navigationBar.barTintColor = .bkRed
                navigationController?.navigationBar.tintColor = .white
                self.animateShopIfNeeded()
            case "showShopInfoFromShopVC":
                guard let vc = segue.destination as? ShopDetailVC else { break }
                vc.avshop = self.avshop
            case "showLoginFromShopVC":
                guard let vc = segue.destination as? MeLoginVC else { break }
                vc.showSegueID = id
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToShopVC(segue: UIStoryboardSegue) {
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func preInit() {
        hideLoadFailedView()
        tryOneMoreTimeBtn.setBorder(with: .bkRed)
        startIndicatorViewAni()
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        originBagBarY = bagBar.frame.origin.y
        originShopY = broadcastLabel.frame.origin.y + 22
        originCardY = shopCardView.frame.origin.y
        originHeadphotoY = hpImage.frame.origin.y
        originNameY = shopNameLabel.frame.origin.y
        originBagViewY = bagView.frame.origin.y
        shopViewStartY = originShopY
        shopView.frame.origin.y = originShopY
        shopView.layoutIfNeeded()
        bagView.frame.origin.y = self.view.frame.height
        bgVisualEffectView.effect = nil
        if !alwaysShowBag {
            // bagBarHeight * ((1 - 0.2) / 2) is the difference value while animating the bag view
            // 'cause it is scaling and transforming position simultaneously
            bagBarBlurView.frame.origin.y = self.view.frame.height + bagBarHeight * ((1 - 0.2) / 2)
            bagBar.alpha = 0.4
            bagBar.frame.origin.y = self.view.frame.height + bagBarHeight * ((1 - 0.2) / 2)
            bagBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
            bagBarBlurView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
        }
        deliveryFeeLabel.alpha = 0
        totalFeeLabel.alpha = 0
        bakeSpecMainView.makeRoundCorder(radius: 10)
    }
    
    func checkAVBaker() {
        if let usr = RealmHelper.retrieveCurrentUser() {
            userRealm = usr
            if let avbaker = self.avbaker {
                if avbaker.objectId != usr.id {
                    self.avbaker = retrieveBaker(withID: usr.id)
                }
            } else {
                self.avbaker = retrieveBaker(withID: usr.id)
            }
            
        }
    }
    
    // MARK: - Page Menu
    func setPageMenu() {
        struct ShopBuy: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "橱窗现货", selectedColor: UIColor.red))
            }
        }
        struct ShopPre: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "美味预约", selectedColor: UIColor.red))
            }
        }
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [ShopBuy(), ShopPre()]
            }
            
            var scroll: MenuScrollingMode
            var displayMode: MenuDisplayMode
            var animationDuration: TimeInterval
            
            var focusMode: MenuFocusMode {
                return .none //underline(height: 3, color: UIColor.red, horizontalPadding: 10, verticalPadding: 0)
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            let shopBuyVC = ShopBuyVC.instantiateFromStoryboard()
            let shopPreVC = ShopPreVC.instantiateFromStoryboard()
            
            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [shopBuyVC, shopPreVC])
            }
            
            var defaultPage: Int
            var isScrollEnabled: Bool
        }
        
        pagingMenuController = self.childViewControllers.first! as! ShopPagingVC
        let option = PagingMenuOptions(defaultPage: 0, isScrollEnabled: true)
        // setup shopBuyVC
        option.shopBuyVC.shopVC = self
        option.shopPreVC.shopVC = self
        option.shopBuyVC.avshop = self.avshop
        option.shopPreVC.avshop = self.avshop
        pagingMenuController.setup(option)
        
        self.shopBuyVC = option.shopBuyVC
        self.shopPreVC = option.shopPreVC
        self.shopBuyVC.bakeTableView.frame.size.height -= self.originBagBarY
        self.shopPreVC.bakeTableView.frame.size.height -= self.originBagBarY
        self.shopBuyVC.classifyTableView.frame.size.height -= self.originBagBarY
        self.shopPreVC.classifyTableView.frame.size.height -= self.originBagBarY
        self.shopBuyVC.bakeTableView.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
        self.shopPreVC.bakeTableView.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
        self.shopCardView.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
        
        pageControllerOnMove()
    }
    
    func pageControllerOnMove() {
        pagingMenuController.onMove = {
            state in
            switch state {
            case .willMoveController(_, _):
                break
            case .didMoveController(_, _):
                switch self.pagingMenuController.currentPage {
                case 0:
                    if self.lastPagingPage == 1 {
                        self.shopBuyVC.reloadAVBakeOrder()
                        self.setShopBagState()
                    }
                case 1:
                    if self.lastPagingPage == 0 {
                        self.shopPreVC.reloadAVBakeOrder()
                        self.setShopBagState()
                    }
                default:
                    break
                }
                self.lastPagingPage = self.pagingMenuController.currentPage
            case .willMoveItem(_, _):
                break
            case .didMoveItem(_, _):
                break
            case .didScrollStart:
                break
            case .didScrollEnd:
                break
            }
        }
    }

    func shopInit() {
        bgImage.sd_setImage(with: URL(string: avshop.bgImage!.url!))
        bgImage.contentMode = .scaleAspectFill
        bgImage.clipsToBounds = true
        
        hpImage.sd_setImage(with: URL(string: avshop.headphoto!.url!))
        hpImage.contentMode = .scaleAspectFill
        hpImage.clipsToBounds = true
        hpImage.layer.cornerRadius = hpImage.frame.size.width / 2
        hpImage.layer.masksToBounds = true
        
        cardBgImage.layer.cornerRadius = 10
        cardBgImage.layer.masksToBounds = true
        
        cardBgImage.layer.shadowColor = UIColor.gray.cgColor
        cardBgImage.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardBgImage.layer.shadowOpacity = 1
        cardBgImage.layer.shadowRadius = 10
        cardBgImage.clipsToBounds = false
        
        shopNameLabel.text = avshop.name!
        if let addr = avshop.address?.formatted {
            addressLabel.setTitle(" \(addr)", for: .normal)
        }
      
        // TODO: - comments
        commentNumberBtn.setTitle("\(423) 评论", for: .normal)
        
        if avshop.deliveryWays!.contains(0) {
            deliveryByShopLabel.textColor = .bkBlack
        } else {
            deliveryByShopLabel.textColor = .lightGray
        }
        if avshop.deliveryWays!.contains(1) {
            takeItYourselfLabel.textColor = .bkBlack
        } else {
            takeItYourselfLabel.textColor = .lightGray
        }
        
        let broadcast = avshop.broadcast!
        if broadcast == "-" {
            broadcastLabel.text = broadcastRandom[Int.random(min: 0, max: broadcastRandom.count - 1)]
        } else {
            broadcastLabel.text = "私房广播：" + broadcast
        }
        
        let width = stars.frame.width
        let star: CGFloat = 4.4
        let x = calStarsWidth(byStarWidth: width, stars: star)
        starLabel.setTitle(String(format: "%.2f", star), for: .normal)
        stars.contentMode = .scaleAspectFill
        stars.image = stars.image!.cropTo(x: 0, y: 0, width: x * 3, height: stars.frame.height * 3, bounds: false)
        stars.frame.size.width = x
        
        bagBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopVC.handleBagBarTap(_:))))
        bagFocusBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopVC.handleBagBarTap(_:))))
    }
    
    // set state of outlets in shop bag view
    func setShopBagState() {
        let lowest = avshop.lowestFee as! Double
        let deliveryFee = avshop.deliveryFee as! Double
        let totalCost = retrieveBakesCost()
        let totalAmount = retrieveBakesCount()
        let shouldReset = totalCost == 0
        let shouldSet = totalCost >= lowest
        let deliveryFeeText = deliveryFee == 0 ? "免费配送" : "另需配送费¥\(deliveryFee.fixPriceTagFormat())"
        self.rightDeliveryFeeLabel.text = deliveryFeeText
        self.deliveryFeeLabel.text = deliveryFeeText
        self.totalFeeLabel.text = "¥\(totalCost.fixPriceTagFormat())"

        if totalAmount == 0 {
            self.totalAmountLabel.text = ""
            self.animateShopIfNeeded()
        } else {
            self.totalAmountLabel.text = "\(totalAmount)"
        }
        
        if shouldSet {
            self.checkBtn.isUserInteractionEnabled = true
            self.checkBtn.setTitle("选好了", for: .normal)
            self.checkBtn.backgroundColor = .appleGreen
            self.emptyBagLabel.alpha = 0
            self.emptyBagLabel.text = emptyBagText
            self.emptyBagLabel.font = UIFont.systemFont(ofSize: self.emptyBagLabel.font.pointSize)
            self.rightLowestFeeLabel.text = ""
            self.rightLowestFeeLabel.alpha = 0
            self.rightDeliveryFeeLabel.alpha = 0
            self.deliveryFeeLabel.alpha = 1
            self.totalFeeLabel.alpha = 1
        } else {
            self.checkBtn.isUserInteractionEnabled = false
            self.checkBtn.setTitle("", for: .normal)
            self.checkBtn.backgroundColor = .checkBtnGray
            self.emptyBagLabel.alpha = 1
            self.emptyBagLabel.text = "¥\(totalCost.fixPriceTagFormat())"
            self.emptyBagLabel.font = UIFont.boldSystemFont(ofSize: self.emptyBagLabel.font.pointSize)
            self.rightLowestFeeLabel.text = "还差¥\((lowest - totalCost).fixPriceTagFormat())起送"
            self.rightLowestFeeLabel.alpha = 1
            self.rightDeliveryFeeLabel.alpha = 1
            self.deliveryFeeLabel.alpha = 0
            self.totalFeeLabel.alpha = 0
        }
        
        if shouldReset {
            self.checkBtn.isUserInteractionEnabled = false
            self.checkBtn.setTitle("", for: .normal)
            self.checkBtn.backgroundColor = .checkBtnGray
            self.emptyBagLabel.alpha = 1
            self.emptyBagLabel.text = emptyBagText
            self.emptyBagLabel.font = UIFont.systemFont(ofSize: self.emptyBagLabel.font.pointSize)
            self.rightLowestFeeLabel.text = "¥\(lowest.fixPriceTagFormat()) 起送"
            self.rightLowestFeeLabel.alpha = 1
            self.rightDeliveryFeeLabel.alpha = 1
            self.deliveryFeeLabel.alpha = 0
            self.totalFeeLabel.alpha = 0
        }
    }
    
    func retrieveBakesCost() -> Double {
        let shopID = avshop.objectId!
        if pagingMenuController.currentPage == 0 {
            return RealmHelper.retrieveBakesInBagCost(avshopID: shopID, avbakesIn: shopBuyVC.avbakesIn)
        } else {
            return RealmHelper.retrieveBakesPreOrderCost(avshopID: shopID, avbakesPre: shopPreVC.avbakesPre)
        }
    }
    
    func retrieveBakesCount() -> Int {
        let shopID = avshop.objectId!
        if pagingMenuController.currentPage == 0 {
            return RealmHelper.retrieveBakesInBagCount(avshopID: shopID, avbakesIn: shopBuyVC.avbakesIn)
        } else {
            return RealmHelper.retrieveBakesPreOrderCount(avshopID: shopID, avbakesPre: shopPreVC.avbakesPre)
        }
    }
    
    func retrieveBakesKindsCount() -> Int {
        let shopID = avshop.objectId!
        if pagingMenuController.currentPage == 0 {
            return RealmHelper.retrieveBakesInBag(avshopID: shopID, avbakesIn: shopBuyVC.avbakesIn).count
        } else {
            return RealmHelper.retrieveBakesPreOrder(avshopID: shopID, avbakesPre: shopPreVC.avbakesPre).count
        }
    }
    
    func setShopBagStateAndTables() {
        setShopBagState()
        shopBuyVC.bakeTableView.reloadData()
        shopBuyVC.classifyTableView.reloadData()
        shopPreVC.bakeTableView.reloadData()
        shopPreVC.classifyTableView.reloadData()
    }

    func animateShopIfNeeded() {
        if bagAniState == .expanded {
            animateShop(.expanded)
        }
    }
    
    func handleBagBarTap(_ sender: UITapGestureRecognizer) {
        let secs = determineSections(avshop, avbakesIn: shopBuyVC.avbakesIn, avbakesPre: shopPreVC.avbakesPre)
        let page = pagingMenuController.currentPage
        if secs == 3 || secs / 2 - 1 == page {
            self.animateShop(self.bagAniState)
        }
    }
    
    
    // MARK: - Checkout
    @IBAction func checkoutBtnPressed(_ sender: Any) {
        if userRealm == nil {
            performSegue(withIdentifier: "showLoginFromShopVC", sender: self)
        } else {
            performSegue(withIdentifier: "showShopCheckingSegue", sender: self)
        }
    }
    
    
    // learn more about the shop
    @IBAction func introBtnPressed(_ sender: Any) {
        
    }
    
    func stopIndicatorViewAni() {
        indicatorSuperView.isHidden = true
        indicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func startIndicatorViewAni() {
        indicatorSuperView.isHidden = false
        indicatorView.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func showLoadFailedView() {
        loadFailedView.isHidden = false
    }
    
    func hideLoadFailedView() {
        loadFailedView.isHidden = true
    }

    @IBAction func tryOneMoreTimeBtnPressed(_ sender: Any) {
        shopBuyVC.loadAVBakes()
        shopPreVC.loadAVBakes()
        hideLoadFailedView()
        startIndicatorViewAni()
    }
    
    
    // MARK: - animation
    // 
    // shop bag animation
    func animateShop(_ state: AniState) {
        switch state {
        case .collapsed:
            shopBagVC.reloadShopBagEmbedTable()
            // compute the height of table view according to the amount of bakes
            var bakesHeight: CGFloat = 0
            for cell in shopBagVC.tableView.visibleCells {
                bakesHeight += cell.frame.height
            }
            let oy = view.frame.height - bagBarHeight - shopBagVC.tableView.frame.origin.y - bakesHeight
            let y = oy < originBagViewY ? originBagViewY : oy
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.bagView.frame.origin.y = y!
                self.bagFocusBgView.alpha = 0.98
                self.shopBagVC.view.backgroundColor = UIColor(hex: self.shopBagVCHeaderColor, alpha: 0.88)
            }, completion: {
                finished in
                self.bagAniState = .expanded
            })
        case .expanded:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.bagView.frame.origin.y = self.view.frame.height
                self.bagFocusBgView.alpha = 0
                self.shopBagVC.view.backgroundColor = .white
            }, completion: {
                finished in
                self.bagAniState = .collapsed
            })
        }
    }
    
    // MARK: - shop menu animations
    // animate the shop main menu view
    func animateMenu(state: AniState) {
        self.view.isUserInteractionEnabled = false
        
        let menuFrameAnimator = self.menuFrameAnimator(duration: menuAniDuration, state: state)
        menuFrameAnimator.startAnimation()
        
        let blurAnimator = self.blurAnimator(duration: menuAniDuration, state: state)
        blurAnimator.startAnimation()
        
        let nameLabelAnimator = self.nameLabelAnimator(duration: menuAniDuration, state: state)
        nameLabelAnimator.startAnimation()
        
        let hpAnimator = self.headphotoAnimator(duration: menuAniDuration, state: state)
        hpAnimator.startAnimation()
        
        let cardAnimator = self.cardAnimator(duration: menuAniDuration, state: state)
        cardAnimator.startAnimation()
        
        let broadcastAnimator = self.broadcastAnimator(duration: menuAniDuration, state: state)
        broadcastAnimator.startAnimation()
        
        if !alwaysShowBag {
            let bagBarAnimator = self.bagBarAnimator(duration: menuAniDuration, state: state)
            bagBarAnimator.startAnimation()
        
            let bagBarBlurAnimator = self.bagBarBlurAnimator(duration: menuAniDuration, state: state)
            bagBarBlurAnimator.startAnimation()
        }

        switchMenuState()
    }
    
    func animateMenu(_ sender: Any) {
        self.animateMenu(self.menuAniState)
    }
    
    // MARK: - interactive animations
    func menuAnimateTransitionIfNeeded(state: AniState, duration: TimeInterval) {
        if runningMenuAnimators.isEmpty {
            shopViewStartY = shopView.frame.origin.y
            
            let menuFrameAnimator = self.menuFrameAnimator(duration: duration, state: state)
            menuFrameAnimator.startAnimation()
            runningMenuAnimators.append(menuFrameAnimator)
            
            let blurAnimator = self.blurAnimator(duration: duration, state: state)
            blurAnimator.startAnimation()
            runningMenuAnimators.append(blurAnimator)
            
            let nameLabelAnimator = self.nameLabelAnimator(duration: duration, state: state)
            nameLabelAnimator.startAnimation()
            runningMenuAnimators.append(nameLabelAnimator)
            
            let hpAnimator = self.headphotoAnimator(duration: duration, state: state)
            hpAnimator.startAnimation()
            runningMenuAnimators.append(hpAnimator)
            
            let cardAnimator = self.cardAnimator(duration: duration, state: state)
            cardAnimator.startAnimation()
            runningMenuAnimators.append(cardAnimator)
            
            let broadcastAnimator = self.broadcastAnimator(duration: duration, state: state)
            broadcastAnimator.startAnimation()
            runningMenuAnimators.append(broadcastAnimator)
            
            if !alwaysShowBag {
                let bagBarAnimator = self.bagBarAnimator(duration: duration, state: state)
                bagBarAnimator.startAnimation()
                runningMenuAnimators.append(bagBarAnimator)
                
                let bagBarBlurAnimator = self.bagBarBlurAnimator(duration: duration, state: state)
                bagBarBlurAnimator.startAnimation()
                runningMenuAnimators.append(bagBarBlurAnimator)
            }
            
            startMenuState = menuAniState
            switchMenuState()
        }
    }
    
    // animators
    func menuFrameAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                self.shopView.frame.origin.y = self.originShopY // hide menu
            case .collapsed:
                self.shopView.frame.origin.y = self.topViewHeight // show menu
            }
        }
        frameAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: frameAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.shopView.frame.origin.y = self.topViewHeight // show menu
                case .collapsed:
                    self.shopView.frame.origin.y = self.originShopY // hide menu
                }
            }
        }
        return frameAnimator
    }
    
    func blurAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        blurAnimator.addAnimations({
            _ in
            switch state {
            case .expanded:
                self.bgVisualEffectView.effect = nil
            case .collapsed:
                self.bgVisualEffectView.effect = UIBlurEffect(style: .extraLight)
            }
        })
        blurAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: blurAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.bgVisualEffectView.effect = UIBlurEffect(style: .extraLight)
                case .collapsed:
                    self.bgVisualEffectView.effect = nil
                }
            }
        }
        return blurAnimator
    }
    
    func nameLabelAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let titleAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                
                self.shopNameLabel.frame.origin.y = self.originNameY - shopVCNameLabelHeight * ((1.12 - 1) / 2)
                self.shopNameLabel.transform = CGAffineTransform.identity // hide menu
            case .collapsed:
                self.shopNameLabel.frame.origin.y = self.originNameY - self.nameLabelTransformY + shopVCNameLabelHeight * ((1.12 - 1) / 2)
                self.shopNameLabel.transform = CGAffineTransform(scaleX: 1.12, y: 1.12) // show menu
            }
        }
        titleAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: titleAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.shopNameLabel.frame.origin.y = self.originNameY - self.nameLabelTransformY
                    self.shopNameLabel.transform = CGAffineTransform(scaleX: 1.12, y: 1.12) // show menu
                case .collapsed:
                    self.shopNameLabel.frame.origin.y = self.originNameY
                    self.shopNameLabel.transform = CGAffineTransform.identity // hide menu
                }
            }
        }
        return titleAnimator
    }
    
    func headphotoAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let headphotoAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                self.hpImage.alpha = 1 // hide menu
                self.hpImage.transform = CGAffineTransform.identity
            case .collapsed:
                self.hpImage.alpha = 0 // show menu
                self.hpImage.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).concatenating(CGAffineTransform(translationX: 0, y: -self.originHeadphotoY))
            }
        }
        headphotoAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: headphotoAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.hpImage.alpha = 0 // show menu
                    self.hpImage.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).concatenating(CGAffineTransform(translationX: 0, y: -self.originHeadphotoY))
                case .collapsed:
                    self.hpImage.alpha = 1 // hide menu
                    self.hpImage.transform = CGAffineTransform.identity
                }
            }
        }
        return headphotoAnimator
    }
    
    func cardAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let cardAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                self.shopCardView.alpha = 1 // hide menu
                self.shopCardView.transform = CGAffineTransform.identity
            case .collapsed:
                self.shopCardView.alpha = 0 // show menu
                self.shopCardView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).concatenating(CGAffineTransform(translationX: 0, y: -self.originCardY))
            }
        }
        cardAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: cardAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.shopCardView.alpha = 0 // show menu
                    self.shopCardView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).concatenating(CGAffineTransform(translationX: 0, y: -self.originCardY))
                case .collapsed:
                    self.shopCardView.alpha = 1 // hide menu
                    self.shopCardView.transform = CGAffineTransform.identity
                }
            }
        }
        return cardAnimator
    }
    
    func broadcastAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let broadcastAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        broadcastAnimator.addAnimations {
            _ in
            switch state {
            case .expanded:
                self.broadcastLabel.alpha = 1 // hide menu
                self.broadcastLabel.transform = CGAffineTransform.identity
            case .collapsed:
                self.broadcastLabel.alpha = 0 // show menu
                self.broadcastLabel.transform = CGAffineTransform(translationX: 0, y: -self.originShopY / 1.41)
            }
        }
        broadcastAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: broadcastAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    self.broadcastLabel.alpha = 0 // show menu
                    self.broadcastLabel.transform = CGAffineTransform(translationX: 0, y: -self.originShopY / 1.42)
                case .collapsed:
                    self.broadcastLabel.alpha = 1 // hide menu
                    self.broadcastLabel.transform = CGAffineTransform.identity
                }
            }
            
            // MARK: - TableView scroll enable or disabled
            self.view.isUserInteractionEnabled = true
            self.shopBuyVC.bakeTableView.visibleCells.forEach { $0.isUserInteractionEnabled = true }
            self.shopBuyVC.bakeTableView.isScrollEnabled = true
            self.shopPreVC.bakeTableView.visibleCells.forEach { $0.isUserInteractionEnabled = true }
            self.shopPreVC.bakeTableView.isScrollEnabled = true
            switch self.menuAniState {
            case .expanded:
                self.shopBuyVC.bakeTableView.shouldScroll = true
                self.shopBuyVC.classifyTableView.isScrollEnabled = true
                self.shopPreVC.bakeTableView.shouldScroll = true
                self.shopPreVC.classifyTableView.isScrollEnabled = true
            case .collapsed:
                self.shopBuyVC.bakeTableView.shouldScroll = false
                self.shopBuyVC.classifyTableView.isScrollEnabled = false
                self.shopPreVC.bakeTableView.shouldScroll = false
                self.shopPreVC.classifyTableView.isScrollEnabled = false
            }
            self.shopViewStartY = self.shopView.frame.origin.y
        }
        return broadcastAnimator
    }
    
    func bagBarAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let bagBarAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        bagBarAnimator.addAnimations {
            _ in
            switch state {
            case .expanded:
                // hide menu
                self.bagBar.alpha = 0.4
                self.bagBar.frame.origin.y = self.view.frame.height + 20
                self.bagBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
            case .collapsed:
                // show menu
                self.bagBar.alpha = 1
                self.bagBar.frame.origin.y = self.originBagBarY + 20
                self.bagBar.transform = CGAffineTransform.identity
            }
        }
        bagBarAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: bagBarAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    // show menu
                    self.bagBar.alpha = 1
                    self.bagBar.frame.origin.y = self.originBagBarY
                    self.bagBar.transform = CGAffineTransform.identity
                case .collapsed:
                    // hide menu
                    self.bagBar.alpha = 0.4
                    self.bagBar.frame.origin.y = self.view.frame.height
                    self.bagBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
                }
            }
        }
        return bagBarAnimator
    }
    
    func bagBarBlurAnimator(duration: TimeInterval, state: AniState) -> UIViewPropertyAnimator {
        let bagBarAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        bagBarAnimator.addAnimations {
            _ in
            switch state {
            case .expanded:
                // hide menu
                self.bagBarBlurView.frame.origin.y = self.view.frame.height + self.bagBarHeight * ((1 - 0.2) / 2)
                self.bagBarBlurView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
                self.bagBarBlurView.effect = nil
            case .collapsed:
                // show menu
                self.bagBarBlurView.frame.origin.y = self.originBagBarY + self.bagBarHeight * ((1 - 0.2) / 2)
                self.bagBarBlurView.transform = CGAffineTransform.identity
                self.bagBarBlurView.effect = UIBlurEffect(style: .dark)
            }
        }
        bagBarAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: bagBarAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    // show menu
                    self.bagBarBlurView.frame.origin.y = self.originBagBarY
                    self.bagBarBlurView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    // hide menu
                    self.bagBarBlurView.frame.origin.y = self.view.frame.height
                    self.bagBarBlurView.effect = nil
                }
            }
        }
        return bagBarAnimator
    }
    
    func menuAnimateOrReverseRunningTransition(state: AniState, duration: TimeInterval) {
        if runningMenuAnimators.isEmpty {
            menuAnimateTransitionIfNeeded(state: state, duration: duration)
        } else {
            runningMenuAnimators.forEach { $0.isReversed = !$0.isReversed }
            switchMenuState()
        }
    }
    
    func switchMenuState() {
        menuAniState = menuAniState == .expanded ? .collapsed : .expanded
    }

    // handle pan gesture
    func panGestureAni(sender: UIPanGestureRecognizer) {
        if !loadFailedView.isHidden || !indicatorSuperView.isHidden { return }
        guard let view = sender.view else { return }
        let velocity = sender.velocity(in: view)
        if shouldReturn(view: view, swipeDown: velocity.y <= 0) { return }
        switch sender.state {
        case .began:
            startTranslationY = sender.location(in: self.view).y
            menuStartInteractiveTransition(state: menuAniState, duration: menuAniDuration)
        case .changed:
            let fraction = computeFraction(sender: sender, velocity: velocity)
            menuUpdateInteractiveTransition(fractionComplete: fraction)
        case .ended:
            let cancel: Bool
            switch menuAniState {
            case .expanded:
                cancel = velocity.y > 0
            case .collapsed:
                cancel = velocity.y < 0
            }
            menuContinueInteractiveTransition(cancel: cancel)
        case .cancelled, .failed:
            menuContinueInteractiveTransition(cancel: true)
        case .possible:
            break
        }
    }
    
    func shouldReturn(view: UIView, swipeDown: Bool) -> Bool {
        if startMenuState == .expanded && swipeDown && shopView.frame.origin.y == topViewHeight { return true }
        if startMenuState == .collapsed && !swipeDown && shopView.frame.origin.y == originShopY { return true }
        if view.classForCoder == ShopBuyBakeTableView.self {
            if shopBuyVC.bakeTableView.contentOffset.y > 0 {
                // watching the menu, return the pan gesture
                return true
            } else if shopBuyVC.bakeTableView.contentOffset.y == 0 {
                if shopViewStartY == topViewHeight {
                    if swipeDown {
                        // start swipe down
                        if runningMenuAnimators.first?.fractionComplete == nil {
                            // starting to watch the menu, return the pan gesture
                            shopBuyVC.bakeTableView.shouldScroll = true
                            shopPreVC.bakeTableView.shouldScroll = true
                            setTableViews(true)
                            return true
                        }
                    } else {
                        // start swipe up
                        setTableViewsAndReset()
                    }
                }
            }
        } else if view.classForCoder == ShopPreBakeTableView.self {
            if shopPreVC.bakeTableView.contentOffset.y > 0 {
                // watching the menu, return the pan gesture
                return true
            } else if shopPreVC.bakeTableView.contentOffset.y == 0 {
                if shopViewStartY == topViewHeight {
                    if swipeDown {
                        // start swipe down
                        if runningMenuAnimators.first?.fractionComplete == nil {
                            // starting to watch the menu, return the pan gesture
                            shopBuyVC.bakeTableView.shouldScroll = true
                            shopPreVC.bakeTableView.shouldScroll = true
                            setTableViews(true)
                            return true
                        }
                    } else {
                        // start swipe up
                        setTableViewsAndReset()
                    }
                }
            }
        } else {
            if !swipeDown {
                setTableViewsAndReset()
            }
        }
        return false
    }
    
    // set table view should enable scroll or user interaction
    func setTableViews(_ enabled: Bool) {
        shopBuyVC.bakeTableView.visibleCells.forEach { $0.isUserInteractionEnabled = enabled }
        shopBuyVC.bakeTableView.isScrollEnabled = enabled
        shopBuyVC.classifyTableView.isScrollEnabled = enabled
        shopPreVC.bakeTableView.visibleCells.forEach { $0.isUserInteractionEnabled = enabled }
        shopPreVC.bakeTableView.isScrollEnabled = enabled
        shopPreVC.classifyTableView.isScrollEnabled = enabled
    }
    
    // set table views and reset the content offset to zero, reset the selection row to index 0.
    func setTableViewsAndReset(reset: Bool = false) {
        setTableViews(reset)
        shopBuyVC.bakeTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        shopBuyVC.classifyTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        shopPreVC.bakeTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        shopPreVC.classifyTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    func menuStartInteractiveTransition(state: AniState, duration: TimeInterval) {
        menuAnimateTransitionIfNeeded(state: state, duration: duration)
        runningMenuAnimators.forEach { $0.pauseAnimation() } // must pause first
        menuProgressWhenInterrupted = runningMenuAnimators.map { $0.fractionComplete }
    }
    
    func computeFraction(sender: UIPanGestureRecognizer, velocity: CGPoint) -> CGFloat {
        let y: CGFloat
        if sender.numberOfTouches == 0 {
            y = lastPanY
        } else {
            y = sender.location(ofTouch: 0, in: self.view).y
            lastPanY = y
        }
        let ty = y - startTranslationY
        let fraction = computeFraction(velocity: velocity, ty: ty, locationY: y)
        return fraction
    }
    
    func computeFraction(velocity: CGPoint, ty: CGFloat, locationY: CGFloat) -> CGFloat {
        var fraction: CGFloat = ty / (originShopY - topViewHeight)
        switch menuAniState {
        case .expanded:
            if velocity.y >= 0 && fraction >= 0 {
                // expanding but paning down
                let progress = menuProgressWhenInterrupted.first!
                if progress == 0 {
                    // not interrupted
                    startTranslationY = locationY   // reset the start translation position
                    fraction = progress
                } else {
                    // interrupted
                    fraction = abs(fraction)
                }
            } else {
                // noraml case
                fraction = abs(fraction)
                if fraction > 1 {
                    startTranslationY -= (fraction - 1) * (originShopY - topViewHeight)
                }
            }
        case .collapsed:
            if velocity.y <= 0 && fraction <= 0 {
                let progress = menuProgressWhenInterrupted.first!
                if progress == 0 {
                    startTranslationY = locationY
                    fraction = progress
                } else {
                    fraction = abs(fraction)
                }
            } else {
                fraction = abs(fraction)
                if fraction > 1 {
                    startTranslationY += (fraction - 1) * (originShopY - topViewHeight)
                }
            }
        }
        // if interrupted
        if let frac = menuProgressWhenInterrupted.first {
            if frac > 0 {
                fraction = ty < 0 ? fraction : -fraction
                fraction = startMenuState == .collapsed ? fraction : -fraction
            }
        }
        return fraction
    }
    
    func menuUpdateInteractiveTransition(fractionComplete: CGFloat) {
        let animatorAndProgress = zip(runningMenuAnimators, menuProgressWhenInterrupted)
        animatorAndProgress.forEach { $0.0.fractionComplete = $0.1 + fractionComplete }
    }
    
    func menuContinueInteractiveTransition(cancel: Bool) {
        if cancel { menuAnimateOrReverseRunningTransition(state: menuAniState, duration: menuAniDuration) }
        runningMenuAnimators.forEach {
            $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    // MARK: - Bake Specification View
    @IBAction func bakeSpecViewCloseBtnPressed(_ sender: Any) {
        hideBakeSpecView()
    }
    
    func hideBakeSpecView() {
        for btns in bakeSpecButtons {
            for btn in btns.value {
                btn.removeFromSuperview()
            }
        }
        currentSpecBtn0 = nil
        UIView.animate(withDuration: 0.18, animations: {
            self.bakeSpecView.alpha = 0
            self.bakeSpecBgFocusView.alpha = 0
        }, completion: { _ in
            self.bakeSpecView.isHidden = true
        })
    }
    
    func showBakeSpecView(bake: AVBake, bakeDetails: [AVBakeDetail]) {
        guard let attributes = bake.attributes else { return }
        switch attributes.count {
        case 1:
            bakeSpecMainView.frame.size.height = 130 + 6
            bakeSpecAttributeLabel0.text = attributes[0] + "："
        case 2:
            bakeSpecMainView.frame.size.height = 130 + 6 + 62
            bakeSpecAttributeLabel0.text = attributes[0] + "："
            bakeSpecAttributeLabel1.text = attributes[1] + "："
        case 3:
            bakeSpecMainView.frame.size.height = 130 + 6 + 62 * 2
            bakeSpecAttributeLabel0.text = attributes[0] + "："
            bakeSpecAttributeLabel1.text = attributes[1] + "："
            bakeSpecAttributeLabel2.text = attributes[2] + "："
        default:
            break
        }
        bakeSpecImageView.image = nil
        bakeSpecView.isHidden = false
        UIView.animate(withDuration: 0.12, animations: {
            self.bakeSpecView.alpha = 1
            self.bakeSpecBgFocusView.alpha = 0.98
        })
        
        bakeSpecButtons = [
            0: [], 1: [], 2: []
        ]
        bakeSpecNameLabel.text = bake.name
        //currentSpecBtn0 = nil // btn 0 will always be set
        currentSpecBtn1 = nil
        currentSpecBtn2 = nil
        
        for bakeDetail in bakeDetails {
            var bakeSpec = ""
            if bakeDetail.attributes?.attribute0?.key == attributes[0] {
                let button = UIButton(frame: bakeSpecAttributeBtn0.frame)
                if bakeSpecButtons[0]?.count == 0 {
                    currentSpecBtn0 = button
                }
                if let spec = bakeDetail.attributes?.attribute0?.value {
                    bakeSpecDict[bakeSpec] = nil
                    bakeSpec += spec
                    if attributes.count == 0 {
                        printit("BakeAttributes: \(bakeDetail.attributes!.objectId!) \(bakeSpec)")
                    }
                    bakeSpecDict[bakeSpec] = bakeDetail
                    setBakeSpecBtn(0, spec: spec, button: button)
                }
            }
            if attributes.count > 1 {
                if bakeDetail.attributes?.attribute1?.key == attributes[1] {
                    let button = UIButton(frame: bakeSpecAttributeBtn0.frame)
                    if bakeSpecButtons[1]?.count == 0 {
                        currentSpecBtn1 = button
                    }
                    if let spec = bakeDetail.attributes?.attribute1?.value {
                        bakeSpecDict[bakeSpec] = nil
                        bakeSpec += spec
                        if attributes.count == 1 {
                            printit("BakeAttributes: \(bakeDetail.attributes!.objectId!) \(bakeSpec)")
                        }
                        bakeSpecDict[bakeSpec] = bakeDetail
                        setBakeSpecBtn(1, spec: spec, button: button)
                    }
                }
                if attributes.count > 2 {
                    if bakeDetail.attributes?.attribute2?.key == attributes[2] {
                        let button = UIButton(frame: bakeSpecAttributeBtn0.frame)
                        if bakeSpecButtons[2]?.count == 0 {
                            currentSpecBtn2 = button
                        }
                        if let spec = bakeDetail.attributes?.attribute2?.value {
                            bakeSpecDict[bakeSpec] = nil
                            bakeSpec += spec
                            if attributes.count == 2 {
                                printit("BakeAttributes: \(bakeDetail.attributes!.objectId!) \(bakeSpec)")
                            }
                            bakeSpecDict[bakeSpec] = bakeDetail
                            setBakeSpecBtn(2, spec: spec, button: button)
                        }
                    }
                }
            }
        }
        
        bakeSpecMinusOneBtn.isHidden = true
        bakeSpecAmountLabel.isHidden = true
        
        var bakeSpec = ""
        if let btn = currentSpecBtn0 {
            specBtn0Pressed(btn)
            guard let spec = btn.currentTitle else { return }
            bakeSpec += spec
        }
        if let btn = currentSpecBtn1 {
            specBtn1Pressed(btn)
            guard let spec = btn.currentTitle else { return }
            bakeSpec += spec
        }
        if let btn = currentSpecBtn2 {
            specBtn2Pressed(btn)
            guard let spec = btn.currentTitle else { return }
            bakeSpec += spec
        }
        guard let bakeDetail = bakeSpecDict[bakeSpec] else { return }
        resetBakeSpecBtnLabel(bakeDetail: bakeDetail)
    }

    func resetBakeSpecBtnLabel(bakeDetail: AVBakeDetail) {
        guard let bakeID = bakeDetail.objectId else { return }
        bakeSpecMinusOneBtn.isHidden = true
        bakeSpecAmountLabel.isHidden = true
        if pagingMenuController.currentPage == 0 {
            if let bakeRealm = RealmHelper.retrieveOneBakeInBag(by: bakeID) {
                if bakeRealm.amount > 0 {
                    bakeSpecMinusOneBtn.isHidden = false
                    bakeSpecAmountLabel.isHidden = false
                    bakeSpecAmountLabel.text = "\(bakeRealm.amount)"
                }
            }
        } else {
            if let bakeRealm = RealmHelper.retrieveOneBakePreOrder(by: bakeID) {
                if bakeRealm.amount > 0 {
                    bakeSpecMinusOneBtn.isHidden = false
                    bakeSpecAmountLabel.isHidden = false
                    bakeSpecAmountLabel.text = "\(bakeRealm.amount)"
                }
            }
        }
    }
    
    func setBakeSpecBtn(_ attribute: Int, spec: String, button: UIButton) {
        guard let shouldReturn = bakeSpecButtons[attribute]?.contains(where: { button in
            return button.currentTitle == spec
        }) else { return }
        guard !shouldReturn else { return }
        button.titleLabel?.font = button.titleLabel?.font.withSize(11)
        button.setTitle(spec, for: .normal)
        button.setTitleColor(.bkBlack, for: .normal)
        button.backgroundColor = UIColor(hex: 0xefefef)
        button.makeRoundCorder()
        button.sizeToFit()
        button.frame.size.width += 10
        button.frame.size.height += 4
        if let lastBtn = bakeSpecButtons[attribute]?.last {
            button.frame.origin.x = lastBtn.frame.origin.x + lastBtn.frame.width + 4
        }
        switch attribute {
        case 0:
            button.addTarget(self, action: #selector(ShopVC.specBtn0Pressed), for: .touchUpInside)
            bakeSpecAttributeView0.addSubview(button)
        case 1:
            button.addTarget(self, action: #selector(ShopVC.specBtn1Pressed), for: .touchUpInside)
            bakeSpecAttributeView1.addSubview(button)
        case 2:
            button.addTarget(self, action: #selector(ShopVC.specBtn2Pressed), for: .touchUpInside)
            bakeSpecAttributeView2.addSubview(button)
        default:
            break
        }
        bakeSpecButtons[attribute]?.append(button)
    }
    
    func specBtn0Pressed(_ sender: UIButton) {
        var spec = ""
        guard let spec0 = sender.currentTitle else { return }
        spec += spec0
        if let spec1 = currentSpecBtn1?.currentTitle {
            spec += spec1
        }
        if let spec2 = currentSpecBtn2?.currentTitle {
            spec += spec2
        }
        guard let bakeDetail = bakeSpecDict[spec] else { return }
        guard let price = bakeDetail.price as? Double else { return }
        currentSpecBtn0?.setTitleColor(.bkBlack, for: .normal)
        currentSpecBtn0?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        currentSpecBtn0 = sender
        currentSpecBtn0?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        currentSpecBtn0?.setTitleColor(.bkRed, for: .normal)
        if let imageURL = bakeDetail.image?.url {
            bakeSpecImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        }
        bakeSpecPriceLabel.text = "¥" + price.fixPriceTagFormat()
        resetBakeSpecBtnLabel(bakeDetail: bakeDetail)
    }
    
    func specBtn1Pressed(_ sender: UIButton) {
        var spec = ""
        guard let spec1 = sender.currentTitle else { return }
        if let spec0 = currentSpecBtn0?.currentTitle {
            spec += spec0
        }
        spec += spec1
        if let spec2 = currentSpecBtn2?.currentTitle {
            spec += spec2
        }
        guard let bakeDetail = bakeSpecDict[spec] else { return }
        guard let price = bakeDetail.price as? Double else { return }
        currentSpecBtn1?.setTitleColor(.bkBlack, for: .normal)
        currentSpecBtn1?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        currentSpecBtn1 = sender
        currentSpecBtn1?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        currentSpecBtn1?.setTitleColor(.bkRed, for: .normal)
        if let imageURL = bakeDetail.image?.url {
            bakeSpecImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        }
        bakeSpecPriceLabel.text = "¥" + price.fixPriceTagFormat()
        resetBakeSpecBtnLabel(bakeDetail: bakeDetail)
    }
    
    func specBtn2Pressed(_ sender: UIButton) {
        var spec = ""
        guard let spec2 = sender.currentTitle else { return }
        if let spec0 = currentSpecBtn0?.currentTitle {
            spec += spec0
        }
        if let spec1 = currentSpecBtn1?.currentTitle {
            spec += spec1
        }
        spec += spec2
        guard let bakeDetail = bakeSpecDict[spec] else { return }
        guard let price = bakeDetail.price as? Double else { return }
        currentSpecBtn2?.setTitleColor(.bkBlack, for: .normal)
        currentSpecBtn2?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        currentSpecBtn2 = sender
        currentSpecBtn2?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        currentSpecBtn2?.setTitleColor(.bkRed, for: .normal)
        if let imageURL = bakeDetail.image?.url {
            bakeSpecImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        }
        bakeSpecPriceLabel.text = "¥" + price.fixPriceTagFormat()
        resetBakeSpecBtnLabel(bakeDetail: bakeDetail)
    }
    
    @IBAction func bakeSpecMinusOneBtnPressed(_ sender: Any) {
        guard var spec = currentSpecBtn0?.currentTitle else { return }
        if let spc = currentSpecBtn1?.currentTitle {
            spec += spc
        }
        if let spc = currentSpecBtn2?.currentTitle {
            spec += spc
        }
        guard let bakeDetail = bakeSpecDict[spec] else { return }
        guard let bake = bakeDetail.bake else { return }

        if pagingMenuController.currentPage == 0 {
            if shopBuyVC.minusOneBake(bake: bake, bakeDetail: bakeDetail, amountLabel: bakeSpecAmountLabel) {
                bakeSpecMinusOneBtn.isHidden = true
                bakeSpecAmountLabel.isHidden = true
            }
            shopBuyVC.classifyTableView.reloadData()
        } else {
            if shopPreVC.minusOneBake(bake: bake, bakeDetail: bakeDetail, amountLabel: bakeSpecAmountLabel) {
                bakeSpecMinusOneBtn.isHidden = true
                bakeSpecAmountLabel.isHidden = true
            }
            shopPreVC.classifyTableView.reloadData()
        }
        setShopBagState()
    }
    
    @IBAction func bakeSpecOneMoreBtnPressed(_ sender: Any) {
        guard var spec = currentSpecBtn0?.currentTitle else { return }
        if let spc = currentSpecBtn1?.currentTitle {
            spec += spc
        }
        if let spc = currentSpecBtn2?.currentTitle {
            spec += spc
        }
        guard let bakeDetail = bakeSpecDict[spec] else { return }
        guard let bake = bakeDetail.bake else { return }

        if pagingMenuController.currentPage == 0 {
            if shopBuyVC.oneMoreBake(bake: bake, bakeDetail: bakeDetail, amountLabel: bakeSpecAmountLabel) {
                bakeSpecMinusOneBtn.isHidden = false
                bakeSpecAmountLabel.isHidden = false
                bakeSpecAmountLabel.text = "1"
            }
            shopBuyVC.classifyTableView.reloadData()
        } else {
            if shopPreVC.oneMoreBake(bake: bake, bakeDetail: bakeDetail, amountLabel: bakeSpecAmountLabel) {
                bakeSpecMinusOneBtn.isHidden = false
                bakeSpecAmountLabel.isHidden = false
                bakeSpecAmountLabel.text = "1"
            }
            shopPreVC.classifyTableView.reloadData()
        }
        setShopBagState()
    }
    
    
}

