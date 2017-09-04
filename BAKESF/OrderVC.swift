//
//  OrderVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/14/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

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
    var orderPresentState: OrderPresentState = .one

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

    func loadOrders() {
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
        query.findObjectsInBackground({
            objects, error in
            if let error = error {
                printit("load order error: \(error.localizedDescription)")
                self.showHelperView(with: "获取订单失败，请重试。", indicating: false)
            } else {
                if let orders = objects as? [AVOrder] {
                    for order in orders {
                        // TODO: - load bakes
                    }
                    self.avorders = orders
                    self.hideHelperView()
                    self.refresher.endRefreshing()
                    self.tableView.reloadData()
                } else {
                    self.showHelperView(with: "加载订单失败，请重试。", indicating: false)
                }
            }
        })
    }
    
    @IBAction func tryOneMoreBtnPressed(_ sender: Any) {
        if let _ = avbaker {
            loadOrders()
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
                return UITableViewCell.centerTextCell(with: "查看更多", in: .buttonBlue)
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "orderTableViewCell", for: indexPath) as? OrderTableViewCell {
                    let order = avorders[row]
                    let shop = order.shop!
                    cell.selectionStyle = .none
                    cell.oneMoreBtn.setBorder(with: .buttonBlue)
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
                            break
                        case 1:
                            break
                        default:
                            break
                        }
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
                    break
                case .more:
                    break
                case .all:
                    break
                }
                tableView.deselectRow(at: indexPath, animated: true)
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
        return 160
    }

    func ordersRefresh(_ sender: Any) -> Void {
        orderPresentState = .one
        loadOrders()
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
                            self.loadOrders()
                        }
                    }
                })
            }
        } else {
            self.showHelperView(with: "未登录", btn: "立即登录", indicating: false)
        }
    }
    
}

