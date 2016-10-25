//
//  FilesPreviewsCollectionViewDataSource.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 23.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

class FilesPreviewsCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let attachments: [Attachment]
    let onAttachmentSelected: (Attachment) -> Void
    
    init(attachments: [Attachment], onAttachmentSelected: @escaping (Attachment) -> Void) {
        self.attachments = attachments
        self.onAttachmentSelected = onAttachmentSelected
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostFilePreviewsCollectionViewCell", for: indexPath) as! PostFilesPreviewsCollectionViewCell
        cell.previewImage.kf.setImage(with: attachments[indexPath.row].thumbnailUrl, options: [.transition(.fade(0.2)), .processor(RoundCornerImageProcessor(cornerRadius: 10))])
        cell.attachment = attachments[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! PostFilesPreviewsCollectionViewCell
        cell.previewImage.kf.cancelDownloadTask()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onAttachmentSelected(attachments[indexPath.row])
    }
}
