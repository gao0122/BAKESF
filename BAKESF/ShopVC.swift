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
    
    enum MenuAniState {
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
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var broadcastLabel: UILabel!
    @IBOutlet weak var shopCardView: UIView!
    @IBOutlet weak var cartBar: UIView!
    @IBOutlet weak var cartFocusBgView: UIView!
    @IBOutlet weak var cartBarBlurView: UIVisualEffectView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var distributionFeeLabel: UILabel!
    @IBOutlet weak var totalFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    private var shopBuyVC: ShopBuyVC!
    private var bakeTableView: ShopBuyBakeTableView!
    private var classifyTableView: ShopClassifyTableView!
    
    var avshop: AVShop!
    
    let topViewHeight: CGFloat = 66
    let menuAniDuration: TimeInterval = 0.48
    let nameLabelTransformY: CGFloat = 172
    let cartBarHeight: CGFloat = 50
    var startTranslationY: CGFloat = 0
    var startMenuState: MenuAniState = .collapsed
    var addedPanRecognizer = false
    var originShopY: CGFloat!
    var originCardY: CGFloat!
    var originHeadphotoY: CGFloat!
    var originNameY: CGFloat!
    var shopViewStartY: CGFloat!
    var originCartBarY: CGFloat!
    
    var menuAniState: MenuAniState = .collapsed
    var runningMenuAnimators = [UIViewPropertyAnimator]()
    var menuProgressWhenInterrupted = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preInit()
        
        // page menu
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
        option.shopBuyVC.shopView = self.shopView
        option.shopBuyVC.originShopY = self.originShopY
        option.shopBuyVC.avshop = self.avshop
        pagingMenuController.setup(option)
        
        self.shopBuyVC = option.shopBuyVC
        self.bakeTableView = option.shopBuyVC.bakeTableView
        self.classifyTableView = option.shopBuyVC.classifyTableView
        self.bakeTableView.frame.size.height -= self.originCartBarY
        self.classifyTableView.frame.size.height -= self.originCartBarY
        let pan = UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:)))
        self.shopBuyVC.bakeTableView.addGestureRecognizer(pan)

//        pagingMenuController.onMove = {
//            state in
//            switch state {
//            case let .willMoveController(menuController, previousMenuController):
//                break
//            case let .didMoveController(menuController, previousMenuController):
//                break
//            case let .willMoveItem(menuItemView, previousMenuItemView):
//                break
//            case let .didMoveItem(menuItemView, previousMenuItemView):
//                break
//            case .didScrollStart:
//                break
//            case .didScrollEnd:
//                break
//            }
//        }
        

        self.shopInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }

    
    @IBAction func introBtnPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "shopBuyMenuSegue":
                if let vc = segue.destination as? ShopPagingVC {
                    vc.view.addGestureRecognizer(UIPanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(ShopVC.panGestureAni(sender:))))
                }
            case "shopBuyCartSegue":
                break
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
        originCartBarY = cartBar.frame.origin.y
        originShopY = broadcastLabel.frame.origin.y + 24
        originCardY = shopCardView.frame.origin.y
        originHeadphotoY = hpImage.frame.origin.y
        originNameY = shopNameLabel.frame.origin.y
        shopViewStartY = originShopY
        shopView.frame.origin.y = originShopY
        shopView.layoutIfNeeded()
        bgVisualEffectView.effect = nil
        cartView.frame.origin.y = self.view.frame.height
        // cartBarHeight * ((1 - 0.2) / 2) is the difference value while animating the cart
        // 'cause it is scaling and transforming position simultaneously
        cartBarBlurView.frame.origin.y = self.view.frame.height + cartBarHeight * ((1 - 0.2) / 2)
        cartBarBlurView.effect = UIBlurEffect(style: .dark)
        cartBar.alpha = 0.4
        cartBar.frame.origin.y = self.view.frame.height + cartBarHeight * ((1 - 0.2) / 2)
        cartBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
        cartBarBlurView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
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
        
        let star = 4.4
        let width = stars.frame.width
        let x = width * CGFloat(star / 5) + 0.452
        starLabel.setTitle(String(format: "%.2f", star), for: .normal)
        stars.contentMode = .scaleAspectFill
        stars.image = stars.image!.cropTo(x: 0, y: 0, width: x * 3, height: stars.frame.height * 3, bounds: false)
        stars.frame.size.width = x
    }
    
    // MARK: - interactive animations
    func menuAnimateTransitionIfNeeded(state: MenuAniState, duration: TimeInterval) {
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
            
            let cartBarAnimator = self.cartBarAnimator(duration: duration, state: state)
            cartBarAnimator.startAnimation()
            runningMenuAnimators.append(cartBarAnimator)
            
            let cartBarBlurAnimator = self.cartBarBlurAnimator(duration: duration, state: state)
            cartBarBlurAnimator.startAnimation()
            runningMenuAnimators.append(cartBarBlurAnimator)
            
            startMenuState = menuAniState
            switchMenuState()
        }
    }
    
    // animators
    func menuFrameAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
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
    
    func blurAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
        let timing: UITimingCurveProvider
        switch state {
        case .expanded:
            timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.1, y: 0.7), controlPoint2: CGPoint(x: 0.25, y: 0.9))
        case .collapsed:
            timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.7, y: 0.1), controlPoint2: CGPoint(x: 0.9, y: 0.25))
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
    
    func nameLabelAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
        let titleAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                self.shopNameLabel.frame.origin.y = self.originNameY - 4.1 / 2
                self.shopNameLabel.transform = CGAffineTransform.identity // hide menu
            case .collapsed:
                self.shopNameLabel.frame.origin.y = self.originNameY - self.nameLabelTransformY + 4.1 / 2
                self.shopNameLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // show menu
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
                    self.shopNameLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // show menu
                case .collapsed:
                    self.shopNameLabel.frame.origin.y = self.originNameY
                    self.shopNameLabel.transform = CGAffineTransform.identity // hide menu
                }
            }
        }
        return titleAnimator
    }
    
    func headphotoAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
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
    
    func cardAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
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
    
    func broadcastAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
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
            
            // MARK: - let TableView scroll enable or disabled
            self.bakeTableView.isScrollEnabled = true
            switch self.menuAniState {
            case .expanded:
                self.bakeTableView.shouldScroll = true
                self.classifyTableView.isScrollEnabled = true
            case .collapsed:
                self.bakeTableView.shouldScroll = false
                self.classifyTableView.isScrollEnabled = false
            }
            self.shopViewStartY = self.shopView.frame.origin.y
        }
        return broadcastAnimator
    }
    
    func cartBarAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
        let cartBarAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        cartBarAnimator.addAnimations {
            _ in
            switch state {
            case .expanded:
                // hide menu
                self.cartBar.alpha = 0.4
                self.cartBar.frame.origin.y = self.view.frame.height + 20
                self.cartBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
            case .collapsed:
                // show menu
                self.cartBar.alpha = 1
                self.cartBar.frame.origin.y = self.originCartBarY + 20
                self.cartBar.transform = CGAffineTransform.identity
            }
        }
        cartBarAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: cartBarAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    // show menu
                    self.cartBar.alpha = 1
                    self.cartBar.frame.origin.y = self.originCartBarY
                    self.cartBar.transform = CGAffineTransform.identity
                case .collapsed:
                    // hide menu
                    self.cartBar.alpha = 0.4
                    self.cartBar.frame.origin.y = self.view.frame.height
                    self.cartBar.transform = CGAffineTransform(scaleX: 1, y: 0.2)
                }
            }
        }
        return cartBarAnimator
    }
    
    func cartBarBlurAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
        let cartBarAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
        cartBarAnimator.addAnimations {
            _ in
            switch state {
            case .expanded:
                // hide menu
                self.cartBarBlurView.frame.origin.y = self.view.frame.height + self.cartBarHeight * ((1 - 0.2) / 2)
                self.cartBarBlurView.transform = CGAffineTransform(scaleX: 1, y: 0.2)
                self.cartBarBlurView.effect = nil
            case .collapsed:
                // show menu
                self.cartBarBlurView.frame.origin.y = self.originCartBarY + self.cartBarHeight * ((1 - 0.2) / 2)
                self.cartBarBlurView.transform = CGAffineTransform.identity
                self.cartBarBlurView.effect = UIBlurEffect(style: .dark)
            }
        }
        cartBarAnimator.addCompletion {
            finalPosition in
            if let index = self.runningMenuAnimators.index(of: cartBarAnimator) {
                self.runningMenuAnimators.remove(at: index)
            }
            if finalPosition == .start {
                switch state {
                case .expanded:
                    // show menu
                    self.cartBarBlurView.frame.origin.y = self.originCartBarY
                    self.cartBarBlurView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    // hide menu
                    self.cartBarBlurView.frame.origin.y = self.view.frame.height
                    self.cartBarBlurView.effect = nil
                }
            }
        }
        return cartBarAnimator
    }
    
    func menuAnimateOrReverseRunningTransition(state: MenuAniState, duration: TimeInterval) {
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
            if bakeTableView.contentOffset.y > 0 {
                // watching the menu, return the pan gesture
                return true
            } else if bakeTableView.contentOffset.y == 0 {
                if shopViewStartY == topViewHeight {
                    if swipeDown {
                        // start swipe down
                        if runningMenuAnimators.first?.fractionComplete == nil {
                            // starting to watch the menu, return the pan gesture
                            bakeTableView.shouldScroll = true
                            bakeTableView.isScrollEnabled = true
                            classifyTableView.isScrollEnabled = true
                            return true
                        }
                    } else {
                        // start swipe up
                        bakeTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                        bakeTableView.isScrollEnabled = false
                        classifyTableView.isScrollEnabled = false
                    }
                }
            }
        } else {
            if !swipeDown {
                bakeTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                bakeTableView.isScrollEnabled = false
                classifyTableView.isScrollEnabled = false
            }
        }
        return false
    }
    
    func menuStartInteractiveTransition(state: MenuAniState, duration: TimeInterval) {
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

