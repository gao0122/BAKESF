//
//  SellerVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import AVOSCloud
import LeanCloud


class SellerVC: UIViewController, UIGestureRecognizerDelegate {
    
    enum MenuAniState {
        case expanded
        case collapsed
    }

    @IBOutlet weak var sellerInfoBgImage: UIImageView!
    @IBOutlet weak var introBtn: UIButton!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var cardBgImage: UIImageView!
    @IBOutlet weak var hpImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var starsHover: UIImageView!
    @IBOutlet weak var commentNumberBtn: UIButton!
    @IBOutlet weak var starLabel: UIButton!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var broadcastLabel: UILabel!
    
    private var bakeCollectionView: SellerBuyBakeCollectionView!
    
    let topViewHeight: CGFloat = 78
    var id: Int!
    var ids: String!
    var seller: [String: Any]!

    let menuAniDuration: TimeInterval = 0.39
    var originShopY: CGFloat = 0
    var startTranslationY: CGFloat = 0
    var startMenuState: MenuAniState!
    var addedPanRecognizer = false
    var hasSetSellerVC = false
    
    var menuAniState: MenuAniState = .collapsed
    var runningMenuAnimators = [UIViewPropertyAnimator]()
    var menuProgressWhenInterrupted = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originShopY = broadcastLabel.frame.origin.y + 24
        shopView.frame.origin.y = originShopY
        
        ids = String(id)
        seller = sellers[ids] as! [String: Any]
        
        // page menu
        struct SellerBuy: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "橱窗现货"))
            }
        }
        struct SellerPre: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "美味预约"))
            }
        }
        struct SellerTweet: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "私房广播"))
            }
        }
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [SellerBuy(), SellerPre(), SellerTweet()]
            }
            
            var scroll: MenuScrollingMode
            var displayMode: MenuDisplayMode
            var animationDuration: TimeInterval
            
            var focusMode: MenuFocusMode {
                return .underline(height: 3, color: UIColor.black, horizontalPadding: 10, verticalPadding: 0)
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            let sellerBuyVC = SellerBuyVC.instantiateFromStoryboard()
            let sellerPreVC = SellerPreVC.instantiateFromStoryboard()
            let sellerTweetVC = SellerTweetVC.instantiateFromStoryboard()

            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [sellerBuyVC, sellerPreVC, sellerTweetVC])
            }
            
            var defaultPage: Int
            var isScrollEnabled: Bool
        }
        
        let pagingMenuController = self.childViewControllers.first! as! PagingMenuController
        let option = PagingMenuOptions(defaultPage: 0, isScrollEnabled: true)
        pagingMenuController.setup(option)
        
        if !self.hasSetSellerVC {
            self.hasSetSellerVC = true
            self.bakeCollectionView = option.sellerBuyVC.bakeCollectionView as! SellerBuyBakeCollectionView!
            option.sellerBuyVC.bakeCollectionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(SellerVC.panGestureAni(sender:))))
        }

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
        

        bgImage.image = UIImage(named: "seller" + ids + "_bg")
        bgImage.contentMode = .scaleAspectFill
        bgImage.clipsToBounds = true
        
        hpImage.image = UIImage(named: "seller" + ids + "_hp")
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

        nameLabel.text = (seller["name"] as! String)
        addressLabel.setTitle(" 广东省珠海市唐家湾金凤路28号", for: .normal)
        commentNumberBtn.setTitle("\(seller["commentsNum"] as! Int) 评论", for: .normal)
        
        let star = seller["stars"] as! Double
        starLabel.setTitle(String(format: "%.2f", star), for: .normal)
        starLabel.setTitle("5.00", for: .normal)
        
        let s = 1 - star / 5
        
        let x = starsHover.frame.width * CGFloat(s)
        print(x)
        // TODO: - stars
        starsHover.frame.origin.x += x
        starsHover.frame.size.width -= x
        
        
        
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
            case "sellerBuyMenuSegue":
                if let vc = segue.destination as? SellerPagingVC {

                }
            case "sellerBuyCartSegue":
                break
            default:
                break
            }
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    @IBAction func screenEdgePanBackToHomeFromSeller(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHomeFromSeller", sender: sender)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    func menuAnimateTransitionIfNeeded(state: MenuAniState, duration: TimeInterval) {
        if runningMenuAnimators.isEmpty {
            let menuFrameAnimator = self.menuFrameAnimator(duration: duration, state: state)
            menuFrameAnimator.startAnimation()
            runningMenuAnimators.append(menuFrameAnimator)
            
            switch state {
            case .collapsed:
                break
            case .expanded:
                break
            }
            switchMenuState()
            startMenuState = menuAniState
        }
    }
    
    func menuFrameAnimator(duration: TimeInterval, state: MenuAniState) -> UIViewPropertyAnimator {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            _ in
            switch state {
            case .expanded:
                self.hideMenu()
            case .collapsed:
                self.showMenu()
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
                    self.showMenu()
                case .collapsed:
                    self.hideMenu()
                }
            }
        }
        return frameAnimator
    }
    

    func menuAnimateOrReverseRunningTransition(state: MenuAniState, duration: TimeInterval) {
        if runningMenuAnimators.isEmpty {
            menuAnimateTransitionIfNeeded(state: state, duration: duration)
        } else {
            runningMenuAnimators.forEach { $0.isReversed = !$0.isReversed }
            switchMenuState()
        }
    }
    
    func showMenu() {
        self.shopView.frame.origin.y = self.topViewHeight
    }
    
    func hideMenu() {
        self.shopView.frame.origin.y = self.originShopY
    }
    
    func switchMenuState() {
        menuAniState = menuAniState == .expanded ? .collapsed : .expanded
    }

    func panGestureAni(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        let velocity = sender.velocity(in: view)
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
    
    func menuStartInteractiveTransition(state: MenuAniState, duration: TimeInterval) {
        menuAnimateTransitionIfNeeded(state: state, duration: duration)
        runningMenuAnimators.forEach { $0.pauseAnimation() }
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
        if menuProgressWhenInterrupted.first! > 0 {
            fraction = ty < 0 ? fraction : -fraction
            fraction = startMenuState == .expanded ? fraction : -fraction
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
        runningMenuAnimators.forEach { $0.continueAnimation(withTimingParameters: timing, durationFactor: 0) }
    }

}



