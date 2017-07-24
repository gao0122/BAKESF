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
    
    private var shopBuyVC: ShopBuyVC!
    private var shopPreVC: ShopPreVC!
    private var shopBagVC: ShopBagEmbedVC!
    
    var avshop: AVShop!
    
    let topViewHeight: CGFloat = 66
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
    
    var menuAniState: AniState = .collapsed
    var runningMenuAnimators = [UIViewPropertyAnimator]()
    var menuProgressWhenInterrupted = [CGFloat]()

    var bagAniState: AniState = .collapsed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preInit()
        setPageMenu()
        shopInit()
        setShopBagState()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "shopBuyMenuSegue":
                if let vc = segue.destination as? ShopPagingVC {
                    vc.view.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
                }
            case "shopBuyBagSegue":
                if let vc = segue.destination as? ShopBagEmbedVC {
                    self.shopBagVC = vc
                }
            default:
                break
            }
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    @IBAction func screenEdgePanBackToHomeFromShop(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHomeFromShop", sender: sender)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func preInit() {
        originBagBarY = bagBar.frame.origin.y
        originShopY = broadcastLabel.frame.origin.y + 22
        originCardY = shopCardView.frame.origin.y
        originHeadphotoY = hpImage.frame.origin.y
        originNameY = shopNameLabel.frame.origin.y
        originBagViewY = bagView.frame.origin.y
        shopViewStartY = originShopY
        shopView.frame.origin.y = originShopY
        shopView.layoutIfNeeded()
        bgVisualEffectView.effect = nil
        bagView.frame.origin.y = self.view.frame.height
        // bagBarHeight * ((1 - 0.2) / 2) is the difference value while animating the bag view
        // 'cause it is scaling and transforming position simultaneously
        bagBarBlurView.frame.origin.y = self.view.frame.height + bagBarHeight * ((1 - 0.2) / 2)
        bagBar.alpha = 0.4
        bagBar.frame.origin.y = self.view.frame.height + bagBarHeight * ((1 - 0.2) / 2)
        bagBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
        bagBarBlurView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
        deliveryFeeLabel.alpha = 0
        totalFeeLabel.alpha = 0
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
        
        let pagingMenuController = self.childViewControllers.first! as! PagingMenuController
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
        
        pagingMenuController.onMove = {
            state in
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                break
            case let .didMoveController(menuController, previousMenuController):
                break
            case let .willMoveItem(menuItemView, previousMenuItemView):
                break
            case let .didMoveItem(menuItemView, previousMenuItemView):
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
        addressLabel.setTitle(" \(avshop.address!)", for: .normal)
        commentNumberBtn.setTitle("\(423) 评论", for: .normal)
        
        let broadcast = avshop.broadcast!
        if broadcast == "-" {
            broadcastLabel.text = broadcastRandom[Int.random(min: 0, max: broadcastRandom.count - 1)]
        } else {
            broadcastLabel.text = "公告：" + broadcast
        }
        
        let width = stars.frame.width
        let star: CGFloat = 4.4
        let x = calStarsWidth(byStarWidth: width, stars: star)
        starLabel.setTitle(String(format: "%.2f", star), for: .normal)
        stars.contentMode = .scaleAspectFill
        stars.image = stars.image!.cropTo(x: 0, y: 0, width: x * 3, height: stars.frame.height * 3, bounds: false)
        stars.frame.size.width = x
        
        bagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShopVC.handleBagBarTap(_:))))
    }
    
    // set state of outlets in shop bag view
    func setShopBagState() {
        let shopID = avshop.objectId!
        let lowest = avshop.lowestFee as! Int
        let totalCost = RealmHelper.retrieveBakesInBagCost(avshopID: shopID)
        let totalAmount = RealmHelper.retrieveBakesInBagCount(avshopID: shopID)
        let shouldReset = totalCost == 0
        let shouldSet = totalCost >= Double(lowest)
        var rightLowestFeeText = shouldSet ? "" : "还差¥\(Double(lowest) - totalCost)起送"
        rightLowestFeeText = shouldReset ? "¥\(lowest) 起送" : rightLowestFeeText
        let deliveryFeeText = avshop.deliveryFee == 0 ? "免费配送" : "另需配送费¥\(avshop.deliveryFee!)"
        self.totalAmountLabel.text = totalAmount == 0 ? "" : "\(totalAmount)"
        self.checkBtn.setTitle(shouldSet ? "结算" : "", for: .normal)
        self.checkBtn.setTitle(shouldReset ? "" : checkBtn.currentTitle!, for: .normal)
        self.checkBtn.backgroundColor = shouldSet ? .appleGreen : .checkBtnGray
        self.checkBtn.backgroundColor = shouldReset ? .checkBtnGray : checkBtn.backgroundColor!
        self.emptyBagLabel.alpha = shouldSet ? 0 : 1
        self.emptyBagLabel.alpha = shouldReset ? 1 : emptyBagLabel.alpha
        self.emptyBagLabel.text = shouldSet ? "购物车空空的" : "¥\(totalCost)"
        self.emptyBagLabel.text = shouldReset ? "购物车空空的" : emptyBagLabel.text!
        self.rightLowestFeeLabel.text = rightLowestFeeText
        self.rightDeliveryFeeLabel.text = deliveryFeeText
        self.deliveryFeeLabel.text = deliveryFeeText
        self.totalFeeLabel.text = "¥\(totalCost)"
        self.rightLowestFeeLabel.alpha = shouldSet ? 0 : 1
        self.rightLowestFeeLabel.alpha = shouldReset ? 1 : rightLowestFeeLabel.alpha
        self.rightDeliveryFeeLabel.alpha = shouldSet ? 0 : 1
        self.rightDeliveryFeeLabel.alpha = shouldReset ? 1 : rightDeliveryFeeLabel.alpha
        self.deliveryFeeLabel.alpha = shouldSet ? 1 : 0
        self.deliveryFeeLabel.alpha = shouldReset ? 0 : deliveryFeeLabel.alpha
        self.totalFeeLabel.alpha = shouldSet ? 1 : 0
        self.totalFeeLabel.alpha = shouldReset ? 0 : totalFeeLabel.alpha
    }

    func handleBagBarTap(_ sender: UITapGestureRecognizer) {
        // TODO: - Show or hide shop bag
        animateShop(bagAniState)
    }
    
    // learn more about the shop
    @IBAction func introBtnPressed(_ sender: Any) {
        
    }
    
    // learn more about the shop
    @IBAction func checkBtnPressed(_ sender: Any) {
        // TODO: - Check if bake in bag is sold out
    }
    

    
    // MARK: - animation
    // 
    // shop bag animation
    func animateShop(_ state: AniState) {
        switch state {
        case .collapsed:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                self.bagView.frame.origin.y = self.originShopY
                self.bagFocusBgView.alpha = 0.4
            }, completion: nil)
        case .expanded:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.bagView.frame.origin.y = self.view.frame.height
                self.bagFocusBgView.alpha = 0
            }, completion: nil)
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
        
        let bagBarAnimator = self.bagBarAnimator(duration: menuAniDuration, state: state)
        bagBarAnimator.startAnimation()
        
        let bagBarBlurAnimator = self.bagBarBlurAnimator(duration: menuAniDuration, state: state)
        bagBarBlurAnimator.startAnimation()

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
            
            let bagBarAnimator = self.bagBarAnimator(duration: duration, state: state)
            bagBarAnimator.startAnimation()
            runningMenuAnimators.append(bagBarAnimator)
            
            let bagBarBlurAnimator = self.bagBarBlurAnimator(duration: duration, state: state)
            bagBarBlurAnimator.startAnimation()
            runningMenuAnimators.append(bagBarBlurAnimator)
            
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
        let timing: UITimingCurveProvider
        switch state {
        case .expanded:
            timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.4, y: 0.6), controlPoint2: CGPoint(x: 0.6, y: 0.8))
        case .collapsed:
            timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.6, y: 0.4), controlPoint2: CGPoint(x: 0.8, y: 0.6))
        }
        let blurAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
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
        guard let view = sender.view else { return }
        let velocity = sender.velocity(in: view)
        if shouldReturn(view: view, swipeDown: velocity.y <= 0) { return }
        switch sender.state {
        case .began:
            startTranslationY = sender.location(in: self.view).y
            menuStartInteractiveTransition(state: menuAniState, duration: menuAniDuration)
        case .changed:
            if sender.numberOfTouches == 0 { break }
            let y = sender.location(ofTouch: 0, in: self.view).y
            let ty = y - startTranslationY
            let fraction = computeFraction(velocity: velocity, ty: ty, locationY: sender.location(ofTouch: 0, in: self.view).y)
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
        if view.classForCoder == ShopBuyBakeTableView.self {
            if shopBuyVC.bakeTableView.contentOffset.y > 0 || shopPreVC.bakeTableView.contentOffset.y > 0 {
                // watching the menu, return the pan gesture
                return true
            } else if shopBuyVC.bakeTableView.contentOffset.y == 0 && shopPreVC.bakeTableView.contentOffset.y == 0 {
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
    func setTableViewsAndReset() {
        setTableViews(false)
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
        if menuProgressWhenInterrupted.first! > 0 {
            fraction = ty < 0 ? fraction : -fraction
            fraction = startMenuState == .collapsed ? fraction : -fraction
        }
        return fraction
    }
    
    func menuUpdateInteractiveTransition(fractionComplete: CGFloat) {
        let animatorAndProgress = zip(runningMenuAnimators, menuProgressWhenInterrupted)
        animatorAndProgress.forEach { $0.0.fractionComplete = $0.1 + fractionComplete }
    }
    
    func menuContinueInteractiveTransition(cancel: Bool) {
        if cancel {
            menuAnimateOrReverseRunningTransition(state: menuAniState, duration: menuAniDuration)
        }
        let timing = UISpringTimingParameters(dampingRatio: 1)
        runningMenuAnimators.forEach { $0.continueAnimation(withTimingParameters: timing, durationFactor: 1) }
    }

    
}

