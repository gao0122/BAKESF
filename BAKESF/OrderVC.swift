//
//  OrderVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/14/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class OrderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }


    override func viewDidAppear(_ animated: Bool) {
        if !animated { return }
        guard let tabBarController = self.tabBarController else { return }
        tabBarController.tabBar.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !animated { return }
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame.origin.y = screenHeight
    }
    

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

