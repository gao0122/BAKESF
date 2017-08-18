//
//  RedPacketVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class RedPacketVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var baker: AVBaker?
    var redPackets: [AVRedPacket]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }


    class func instantiateFromStoryboard() -> RedPacketVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! RedPacketVC
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redPackets == nil ? 1 : redPackets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _ = baker {
            if redPackets == nil {
                let cell = UITableViewCell.centerTextCell(with: "暂无可用红包", in: .bkBlack)
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "redPacketTableViewCell", for: indexPath) as! RedPacketTableViewCell
                return cell
            }
        } else {
            return UITableViewCell.centerTextCell(with: "立即登录", in: .buttonBlue)
        }
    }
    
}
