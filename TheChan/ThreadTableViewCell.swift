//
//  ThreadTableViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 14.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class ThreadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var omittedPostsLabel: UILabel!
    @IBOutlet weak var omittedPostsNounLabel: UILabel!
    
    @IBOutlet weak var omittedFilesLabel: UILabel!
    @IBOutlet weak var omittedFilesNounLabel: UILabel!
    
    @IBOutlet weak var opPostImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHorizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageVerticalSpacingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
