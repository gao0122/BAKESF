//
//  ShopPreVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class ShopPreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var classifyTableView: ShopClassifyTableView!
    @IBOutlet weak var bakeTableView: ShopPreBakeTableView!

    var shopVC: ShopVC!
    var avshop: AVShop!
    var avtag: [String]!
    var avbakes: [AVBake]!
    var avbakesTag = [String: [AVBake]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    class func instantiateFromStoryboard() -> ShopPreVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! ShopPreVC
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = classifyTableView.dequeueReusableCell(withIdentifier: "shopClassifyTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! ShopClassifyTableCell
            let bgView = UIView()
            bgView.backgroundColor = .white
            cell.selectedBackgroundView = bgView
            cell.backgroundColor = UIColor(hex: 0xEFEFEF)
            cell.layer.cornerRadius = 2
            cell.classLabel.textColor = .bkBlack
            //cell.classLabel.text = avtag[indexPath.row] TODO
            return cell
        case 1:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
