//
//  SellerVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController

class SellerVC: UIViewController {
    
    @IBOutlet weak var sellerInfoBgImage: UIImageView!
    @IBOutlet weak var introBtn: UIButton!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var cardBgImage: UIImageView!
    @IBOutlet weak var hpImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var stars: UICollectionView!
    @IBOutlet weak var starsHover: UIImageView!
    @IBOutlet weak var commentNumberBtn: UIButton!
    @IBOutlet weak var starLabel: UIButton!
    
    var id: Int!
    var ids: String!
    var seller: [String: Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        id = RealmHelper.retrieveCurrentSellerID()
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
        pagingMenuController.onMove = {
            state in
            
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                print()
                
            case let .didMoveController(menuController, previousMenuController):
                print()
                
            case let .willMoveItem(menuItemView, previousMenuItemView):
                print()
                
            case let .didMoveItem(menuItemView, previousMenuItemView):
                print()
                
            case .didScrollStart:
                print()
                
            case .didScrollEnd:
                print()
                
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
        
        starsHover.frame.origin.x += x
        starsHover.frame.size.width -= x
    }

    @IBAction func introBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func screenEdgePanBackToHome(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHomeFromSeller", sender: sender)
    }
    
}



let sellers: [String: Any] = [
    "0": [
        "name": "北欧宜家小食",
        "comments": [
            ["user": "primo", "content": "delicious!"],
            ["user": "primo", "content": "delicious!"]
        ],
        "commentsNum": 423,
        "stars": 4.5,
        "topics": ["#私家烘焙", "#焙可推荐"],
        
        "bakes": [
            "0": ["name": "名媛塔", "price": 36.00, "star": 4.2, "amount": 5],
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 0],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 0],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 0],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 0],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 0],
            "9": ["name": "黄桃家", "price": 189.00, "star": 4.6, "amount": 1]
        ]
    ],
    "1": [
        "name": "南墨尔本的克莱门",
        "comments": ["user": "primo", "content": "good good good!"],
        "commentsNum": 208,
        "stars": 4.8,
        "topics": ["#北美"],
        
        "bakes": [
            "0": ["name": "名媛塔", "price": 36.00, "star": 4.2, "amount": 5],
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 0],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 0],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 0],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 0],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 0],
            "9": ["name": "黄桃家", "price": 189.00, "star": 4.6, "amount": 1]
        ]
        
    ],
    "2": [
        "name": "甜品师 Megan 的店",
        "comments": ["user": "primo", "content": "very nice try!"],
        "commentsNum": 1922,
        "stars": 4.9,
        "topics": [],
        
        "bakes": [
            "0": ["name": "名媛塔", "price": 36.00, "star": 4.2, "amount": 5],
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 0],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 0],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 0],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 0],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 0],
            "9": ["name": "黄桃家", "price": 189.00, "star": 4.6, "amount": 1]
        ]
        
    ],
    "3": [
        "name": "茵茵的厨房",
        "comments": ["user": "primo", "content": "wow!"],
        "commentsNum": 879,
        "stars": 4.4,
        "topics": ["#烘焙教学", "#焙可推荐"],
        
        "bakes": [
            "0": ["name": "名媛塔", "price": 36.00, "star": 4.2, "amount": 5],
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 0],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 0],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 0],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 0],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 0],
            "9": ["name": "黄桃家", "price": 189.00, "star": 4.6, "amount": 1]
        ]
        
    ]
]

