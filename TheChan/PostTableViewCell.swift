//
//  PostTableViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var filesPreviewsCollectionView: UICollectionView!
    @IBOutlet weak var postContentView: UITextView!
    var attachments = [Attachment]()
    var onAttachmentSelected: (Attachment) -> Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postContentView.textContainerInset = UIEdgeInsetsMake(
            0,
            -postContentView.textContainer.lineFragmentPadding,
            0,
            -postContentView.textContainer.lineFragmentPadding)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostFilePreviewsCollectionViewCell", for: indexPath) as! PostFilesPreviewsCollectionViewCell
        let attachment = attachments[indexPath.item]
        
        cell.attachment = attachment
        cell.previewImage.kf.setImage(with: attachment.thumbnailUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAttachment = attachments[indexPath.item]
        onAttachmentSelected(selectedAttachment)
    }
}
