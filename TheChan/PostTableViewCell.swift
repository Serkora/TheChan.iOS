//
//  PostTableViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

private let previewReuseIdentifier = "PostFilePreviewsCollectionViewCell"
private let replyReuseIdentifier = "RepliesCollectionViewCell"

class PostTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var filesPreviewsCollectionView: UICollectionView!
    @IBOutlet weak var repliesCollectionView: UICollectionView!
    @IBOutlet weak var postContentView: UITextView!
    var attachments = [Attachment]()
    var replies = [Int]()
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
    
    override func prepareForReuse() {
        backgroundColor = UIColor.clear
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filesPreviewsCollectionView {
            return attachments.count
        } else if collectionView == repliesCollectionView {
            return replies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filesPreviewsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewReuseIdentifier, for: indexPath) as! PostFilesPreviewsCollectionViewCell
            let attachment = attachments[indexPath.item]
        
            cell.attachment = attachment
            cell.previewImage.kf.setImage(with: attachment.thumbnailUrl)
            return cell
        } else if collectionView == repliesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: replyReuseIdentifier, for: indexPath) as! RepliesCollectionViewCell
            
            cell.thisPostNumber = Int(numberLabel.text!)
            cell.replyPostNumber = replies[indexPath.item]
            cell.replyPostNumberLabel.text = ">>" + String(cell.replyPostNumber)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filesPreviewsCollectionView {
            let selectedAttachment = attachments[indexPath.item]
            onAttachmentSelected(selectedAttachment)
        }
    }
}
