//
//  TableViewCell.swift
//  AppStoreListTest
//
//  Created by 罗泰 on 2018/8/24.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK: - Animation
extension TableViewCell {
    func startAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
            self.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
        }) { (finish) in
            self.isUserInteractionEnabled = true
        }
    }
    
    func endAnimation() {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform.identity
        }) { (finish) in
            self.isUserInteractionEnabled = true
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
}
