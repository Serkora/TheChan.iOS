//
//  FavoriteThreadCollectionViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class FavoriteThreadCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var boardLabel: UILabel!
    @IBOutlet weak var threadNameLabel: UILabel!
    @IBOutlet weak var unreadPostsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.25
        layer.shadowPath = shadowPath.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.cgPath
    }
}
