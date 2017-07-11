//
//  SellerPagingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/6/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController

class SellerPagingVC: PagingMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}

var sellers: [String: Any] = [
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
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 10],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 4],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 20],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 23],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 19],
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
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 10],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 4],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 20],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 23],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 19],
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
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 10],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 4],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 20],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 23],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 19],
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
            "1": ["name": "咖喱披萨", "price": 99.00, "star": 3.0, "amount": 10],
            "2": ["name": "巧克力布丁", "price": 12.00, "star": 4.5, "amount": 2],
            "3": ["name": "巧克力条", "price": 52.00, "star": 3.1, "amount": 6],
            "4": ["name": "春之物语", "price": 128.00, "star": 4.3, "amount": 4],
            "5": ["name": "樱桃派", "price": 218.00, "star": 2.5, "amount": 20],
            "6": ["name": "海森林", "price": 146.00, "star": 4.6, "amount": 23],
            "7": ["name": "草莓杯子蛋糕", "price": 28.00, "star": 2.9, "amount": 1],
            "8": ["name": "蓝莓蛋糕", "price": 98.00, "star": 4.0, "amount": 19],
            "9": ["name": "黄桃家", "price": 189.00, "star": 4.6, "amount": 1]
        ]
    ]
]

