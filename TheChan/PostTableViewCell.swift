//
//  PostTableViewCell.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

private let previewReuseIdentifier = "PostFilesPreviewsCollectionViewCell"

class PostTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var filesPreviewsCollectionView: UICollectionView!
    @IBOutlet weak var postContentView: UITextView!
    @IBOutlet weak var repliesButton: UIButton!
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
    var delegate: PostTableViewCellDelegate? = nil
    var attachments = [Attachment]()
    var post = Post()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        filesPreviewsCollectionView.register(UINib(nibName: previewReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: previewReuseIdentifier)
        
        postContentView.textContainerInset = UIEdgeInsetsMake(
            0,
            -postContentView.textContainer.lineFragmentPadding,
            0,
            -postContentView.textContainer.lineFragmentPadding)
        
        postContentView.delegate = self
    }
    
    @available(iOS 10, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return handleURLForPostPreview(URL, type: (interaction == .preview) ? .peekAndPop : .regular)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return handleURLForPostPreview(URL, type: .regular)
    }
    
    func handleURLForPostPreview(_ url: URL, type: PostPreviewType) -> Bool {
        if url.scheme != "post" {
            return true
        }
        
        
        let number = Int(url.host ?? "0")!
        delegate?.postPreviewRequested(sender: self, postNumber: number, type: type)
        return false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewReuseIdentifier, for: indexPath) as! PostFilesPreviewsCollectionViewCell
        let attachment = attachments[indexPath.item]
        
        cell.attachment = attachment
        cell.previewImage.kf.setImage(with: attachment.thumbnailUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAttachment = attachments[indexPath.item]
        delegate?.attachmentSelected(sender: self, attachment: selectedAttachment)
    }
    
    
    @IBAction func repliesButtonTapped(_ sender: Any) {
        delegate?.repliesButtonTapped(sender: self)
    }
}

enum PostPreviewType {
    case regular, peekAndPop
}

protocol PostTableViewCellDelegate {
    func repliesButtonTapped(sender: PostTableViewCell)
    func attachmentSelected(sender: PostTableViewCell, attachment: Attachment)
    func postPreviewRequested(sender: PostTableViewCell, postNumber: Int, type: PostPreviewType)
}

extension PostTableViewCellDelegate {
    func repliesButtonTapped(sender: PostTableViewCell) {}
    func attachmentSelected(sender: PostTableViewCell, attachment: Attachment) {}
    func postPreviewRequested(sender: PostTableViewCell, postNumber: Int, type: PostPreviewType) {}
}
