//
//  PostTableViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var filesPreviewsCollectionView: UICollectionView!
    var previewsSource: UICollectionViewDataSource? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
