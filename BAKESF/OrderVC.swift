//
//  OrderVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/14/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

class OrderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum OrderPresentState {
        case one, more, all
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tryOneMoreTimeBtn: UIButton!
    @IBOutlet weak var tableFooterView: UIView!
    
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(OrderVC.ordersRefresh(_:)), for: UIControlEvents.valueChanged)
        return refresher
    }()

    var user: UserRealm? {
        return RealmHelper.retrieveCurrentUser()
    }
    var avbaker: AVBaker?
    var avorders = [AVOrder]()
    var avbakesDict = [AVOrder: [AVObject]]()
    var orderPresentState: OrderPresentState = .one
    
    var lastTableViewCellText = "查看更多"
    let OrderTableViewCellHeight: CGFloat = 128

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white

        view.bringSubview(toFront: helperView)
        
        tableView.addSubview(refresher)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
    }

    override func viewDidAppear(_ animated: Bool) {
        checkCurrentUser()
        guard let tabBarController = self.tabBarController else { return }
        tabBarController.tabBar.isHidden = false
        let duration: TimeInterval = animated ? 0.17 : 0
        UIView.animate(withDuration: duration, animations: {
            tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
        }, completion: {
            _ in
            tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame.origin.y = screenHeight
    }
    
    
    // MARK: Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "showLoginFromOrder":
            show(segue.destination, sender: sender)
        default:
            break
        }
    }

    func loadOrdersAndBakes() {
        guard let avbaker = self.avbaker else { return }
        let query = AVOrder.query()
        query.addDescendingOrder("createAt")
        query.whereKey("baker", equalTo: avbaker)
        query.includeKey("baker")
        query.includeKey("shop")
        query.includeKey("shop.headphoto")
        query.includeKey("deliveryAddress")
        switch orderPresentState {
        case .one:
            query.limit = 1
        case .more:
            query.limit = 5
        case .all:
            break
        }

        var isSucceeded = true
        let group = DispatchGroup()
        group.enter()
        query.findObjectsInBackground({
            objects, error in
            if let error = error {
                printit("load order error: \(error.localizedDescription)")
                isSucceeded = false
                self.showHelperView(with: "获取订单失败，请重试。", indicating: false)
            } else {
                if let orders = objects as? [AVOrder] {
                    self.avorders = orders
                    for order in orders {
                        // TODO: - load bakes
                        if order.type == NSNumber(value: 0) {
                            // AVBakeIn
                            let query = AVBakeIn.query()
                            query.whereKey("order", equalTo: order)
                            query.includeKey("order")
                            query.includeKey("order.shop")
                            query.includeKey("bake")
                            query.includeKey("bakee")
                            group.enter()
                            query.findObjectsInBackground({
                                objects, error in
                                if let error = error {
                                    printit("load bakes in error: \(error.localizedDescription)")
                                    isSucceeded = false
                                } else {
                                    if let bakes = objects as? [AVBakeIn] {
                                        self.avbakesDict[order] = bakes
                                    } else {
                                        isSucceeded = false
                                    }
                                }
                                group.leave()
                            })
                        } else if order.type == NSNumber(value: 1) {
                            // AVBakePre
                            let query = AVBakePre.query()
                            query.whereKey("order", equalTo: order)
                            query.includeKey("order.shop")
                            query.includeKey("bake")
                            query.includeKey("bakee")
                            group.enter()
                            query.findObjectsInBackground({
                                objects, error in
                                if let error = error {
                                    printit("load bakes pre error: \(error.localizedDescription)")
                                    isSucceeded = false
                                } else {
                                    if let bakes = objects as? [AVBakePre] {
                                        self.avbakesDict[order] = bakes
                                    } else {
                                        isSucceeded = false
                                    }
                                }
                                group.leave()
                            })
                        }
                    }
                } else {
                    self.showHelperView(with: "加载订单失败，请重试。", indicating: false)
                }
            }
            group.leave()
        })
        group.notify(queue: DispatchQueue.main, execute: {
            if isSucceeded {
                self.hideHelperView()
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.showHelperView(with: "订单加载失败", indicating: false)
            }
        })
    }
    
    @IBAction func tryOneMoreBtnPressed(_ sender: Any) {
        if let _ = avbaker {
            loadOrdersAndBakes()
        } else {
            let segue = UIStoryboardSegue.init(identifier: "showLoginFromOrder", source: self, destination: MeLoginVC.instantiateFromStoryboard())
            prepare(for: segue, sender: self)
            performSegue(withIdentifier: "showLoginFromOrder", sender: self)
        }
    }

    func showHelperView(with labelText: String = "", btn btnText: String = "再试一次", indicating: Bool) {
        helperView.isHidden = false
        indicatorView.isHidden = !indicating
        helperLabel.isHidden = indicating
        tryOneMoreTimeBtn.isHidden = indicating
        if indicating {
            indicatorView.startAnimating()
        } else {
            helperLabel.text = labelText
            tryOneMoreTimeBtn.setTitle(btnText, for: .normal)
            indicatorView.stopAnimating()
        }
    }
    
    func hideHelperView() {
        helperView.isHidden = true
        indicatorView.stopAnimating()
    }
    
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avorders.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let row = indexPath.row
            if row == avorders.count {
                return UITableViewCell.centerTextCell(with: self.lastTableViewCellText, in: .buttonBlue)
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "orderTableViewCell", for: indexPath) as? OrderTableViewCell {
                    let order = avorders[row]
                    let shop = order.shop!
                    cell.selectionStyle = .none
                    cell.btn.setBorder(with: .buttonBlue)
                    cell.shopNameBtn.setTitle(shop.name!, for: .normal)
                    cell.shopNameBtn.sizeToFit()
                    cell.createdAtLabel.text = order.createdAt?.formatted()
                    if let url = shop.headphoto?.url {
                        cell.avatarIV.sd_setImage(with: URL(string: url), completed: {
                            _ in
                            cell.avatarIV.contentMode = .scaleAspectFill
                            cell.avatarIV.clipsToBounds = true
                            cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2
                            cell.avatarIV.layer.masksToBounds = true
                        })
                    } else {
                        cell.avatarIV.image = UIImage(named: "蓝莓蛋糕")
                        cell.avatarIV.contentMode = .scaleAspectFill
                        cell.avatarIV.clipsToBounds = true
                        cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2
                        cell.avatarIV.layer.masksToBounds = true
                    }
                    cell.stateLabel.text = ""
                    if let status = order.status as? Int {
                        switch status {
                        case 0:
                            cell.stateLabel.text = "等待付款"
                            cell.btn.isHidden = false
                            cell.btn.setTitle("去付款", for: .normal)
                        case 1:
                            cell.stateLabel.text = "等待卖家接单"
                            cell.btn.isHidden = true
                        case 3:
                            cell.stateLabel.text = "等待配送"
                            cell.btn.isHidden = true
                        case 4:
                            cell.stateLabel.text = "正在配送"
                            cell.btn.isHidden = true
                        case 5:
                            cell.stateLabel.text = "已送达"
                            cell.btn.isHidden = false
                            cell.btn.setTitle("确认收货", for: .normal)
                        case 6:
                            cell.stateLabel.text = "待评价"
                            cell.btn.isHidden = false
                            cell.btn.setTitle("评价", for: .normal)
                        case 7:
                            cell.stateLabel.text = "待确认收货"
                            cell.btn.isHidden = false
                            cell.btn.setTitle("确认收货", for: .normal)
                        case 8:
                            cell.stateLabel.text = "已完成"
                            cell.btn.isHidden = false
                            cell.btn.setTitle("再来一单", for: .normal)
                        default:
                            break
                        }
                    }
                    if let avbakes = avbakesDict[order] {
                        var bakesInfoText = ""
                        if let bake = avbakes.first as? AVBakeIn {
                            bakesInfoText = bake.bakee.name!
                        } else if let bake = avbakes.first as? AVBakePre {
                            bakesInfoText = bake.bakee.name!
                        }
                        bakesInfoText += " 等\(avbakes.count)件商品"
                        cell.bakesInfoLabel.text = bakesInfoText
                        cell.priceLabel.text = "\(String(describing: order.totalCost!))元"
                    }
                    return cell
                }
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section {
        case 0:
            let row = indexPath.row
            if row == avorders.count {
                switch orderPresentState {
                case .one:
                    lastTableViewCellText = "查看更多"
                    orderPresentState = .more
                    loadOrdersAndBakes()
                case .more:
                    lastTableViewCellText = "查看全部"
                    orderPresentState = .all
                    loadOrdersAndBakes()
                case .all:
                    lastTableViewCellText = "已经是全部订单啦"
                    break
                }
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            let row = indexPath.row
            if row == avorders.count {
                return 50
            }
        default:
            break
        }
        return OrderTableViewCellHeight
    }

    func ordersRefresh(_ sender: Any) -> Void {
        orderPresentState = .one
        loadOrdersAndBakes()
    }
    

    func checkCurrentUser() {
        if let usr = self.user {
            if let _ = avbaker {
                // logged in
            } else {
                showHelperView(indicating: true)
                retrieveBaker(withID: usr.id, completion: {
                    object, error in
                    if let error = error {
                        printit("Retrieve Baker Error: \(error.localizedDescription)")
                        self.showHelperView(with: "当前用户获取失败。", btn: "重新登录", indicating: false)
                    } else {
                        if let baker = object as? AVBaker {
                            self.avbaker = baker
                            self.loadOrdersAndBakes()
                        }
                    }
                })
            }
        } else {
            self.showHelperView(with: "未登录", btn: "立即登录", indicating: false)
        }
    }
    
}

