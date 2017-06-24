//
//  SellerBuyVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/7/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class SellerBuyVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var bakeCollectionView: UICollectionView!
    
    var bake: [String: Any]!
    var bakes: [String: Any]!
    var buyBake = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bakeCollectionView.dataSource = self
        bakeCollectionView.allowsSelection = false
        
        
        bake = sellers["\(RealmHelper.retrieveCurrentSellerID())"] as! [String : Any]
        bakes = bake["bakes"] as! [String: Any]

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = bakeCollectionView.dequeueReusableCell(withReuseIdentifier: "sellerBuyBakeTableCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! SellerBuyBakeTableCell
        let bakee = bakes["\(buyBake[indexPath.row])"] as! [String: Any]
        
        let bakeName = bakee["name"] as! String
        let price = bakee["price"] as! Double
        let left = bakee["amount"] as! Int
        // let star = bakee["star"] as! Double

        
        cell.bakeImage.image = UIImage(named: bakeName)
        cell.nameLabel.text = bakeName
        cell.priceLabel.text = "¥\(price)"
        cell.leftLabel.text = "剩余 \(left)"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        var count = bakes.count
        
        for bakee in bakes {
            let bakeInfo = bakee.value as! [String: Any]
            
            if (bakeInfo["amount"] as! Int) <= 0 {
                count -= 1
            } else {
                buyBake.append(Int(bakee.key)!)
            }
        }
        
        return count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    class func instantiateFromStoryboard() -> SellerBuyVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! SellerBuyVC
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
