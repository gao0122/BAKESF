//
//  HomeSellerVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import Alamofire
import QuartzCore

class HomeSellerVC: UIViewController, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: HomeSellerTableView!
    
    
    // TODO :- embeded nav controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.allowsSelection = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class func instantiateFromStoryboard() -> HomeSellerVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! HomeSellerVC
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeSellerTableViewCell") as! HomeSellerTableViewCell
        
        cell.selectionStyle = .none
        
        let seller = sellers["\(indexPath.row)"] as! [String: Any]
        
        cell.nameLabel.text = (seller["name"] as! String)
        
        let commentsNum = seller["commentsNum"] as! Int
        cell.commentsNumber.setTitle("\(commentsNum) 评论", for: .normal)
        
        let topics = seller["topics"] as! [String]
        var topicsStr = ""
        if topics.count > 1 {
            topicsStr.append("\(topics.first!)...")
        } else {
            topicsStr.append("\(topics.first ?? "")")
        }
        
        cell.topicButton.setTitle(topicsStr, for: .normal)
        
        let hpName = "seller\(indexPath.row)_hp"
        cell.headphoto.image = UIImage(named: hpName)
        cell.headphoto.contentMode = .scaleAspectFill
        cell.headphoto.clipsToBounds = true
        cell.headphoto.layer.cornerRadius = cell.headphoto.frame.size.width / 2
        cell.headphoto.layer.masksToBounds = true
        
        let bgName = "seller\(indexPath.row)_bg"
        cell.bgImage.image = UIImage(named: bgName)
        cell.bgImage.contentMode = .scaleAspectFill
        cell.bgImage.clipsToBounds = true
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "homeToSeller" {
                
                let sourceVC = segue.source
                sourceVC.tabBarController?.tabBar.isHidden = true
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                
                RealmHelper.updateCurrentSellerID(id: tableView.indexPathForSelectedRow!.row, seller: RealmHelper.retrieveCurrentSeller())
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func unwindToHomeSellerVC(segue: UIStoryboardSegue) {
        segue.source.tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    @IBAction func sellerCellTapped(_ tap: UITapGestureRecognizer) {
        // to seller view page
                
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let sellerVC = storyboard.instantiateViewController(withIdentifier: "SellerVC") as! SellerVC
        
        
        self.present(sellerVC, animated: true, completion: nil)
    }
    
}
