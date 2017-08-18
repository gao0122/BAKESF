//
//  UITableViewCell+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 8/18/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

// MARK :- TableViewCell
public extension UITableViewCell {

    static func centerTextCell(with text: String, in color: UIColor) -> UITableViewCell {
        let cell = UITableViewCell()
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: (cell.frame.width - 300) / 2, y: (cell.frame.height - 24) / 2, width: 300, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleWidth]
            label.text = text
            label.textColor = color
            label.textAlignment = .center
            return label
        }()
        cell.addSubview(label)
        return cell
    }

    static func btnCell(with text: String, in color: UIColor = .bkBlack) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = text
        cell.textLabel?.textColor = color
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: cell.frame.width - 15 - 30, y: (cell.frame.height - 24) / 2, width: 30, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin]
            label.text = ">"
            label.textColor = color
            label.textAlignment = .right
            return label
        }()
        cell.addSubview(label)
        return cell
    }
    
}
