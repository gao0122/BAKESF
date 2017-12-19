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

    static func centerTextCell(with text: String, in color: UIColor, fontSize: CGFloat = 14) -> UITableViewCell {
        let cell = UITableViewCell()
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: (cell.frame.width - 300) / 2, y: (cell.frame.height - 24) / 2, width: 300, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleWidth]
            label.text = text
            label.textColor = color
            label.textAlignment = .center
            label.font = label.font.withSize(fontSize)
            return label
        }()
        cell.addSubview(label)
        return cell
    }

    static func btnCell(with text: String, in color: UIColor = .bkBlack, img: UIImage? = nil, detail: String = "") -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "btnTableViewCell")
        cell.imageView?.image = img
        cell.textLabel?.textColor = color
        cell.detailTextLabel?.text = detail
        cell.accessoryType = .disclosureIndicator
        let label: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 15, y: (cell.frame.height - 24) / 2, width: cell.frame.width - 50, height: 24)
            label.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
            label.text = text
            label.textColor = color
            label.textAlignment = .left
            return label
        }()
        cell.addSubview(label)
        return cell
    }
 
    static func separatorCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(hex: 0xF7F7F7)
        cell.selectionStyle = .none
        cell.separatorInset.left = screenWidth
        return cell
    }
}
