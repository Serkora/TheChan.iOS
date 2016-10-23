//
//  FilesPreviewsCollectionViewDataSource.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 23.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

class FilesPreviewsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    let attachments: [Attachment]
    
    private struct Constants {
        static let imageProcessor = RoundCornerImageProcessor(cornerRadius: 10)
    }
    
    init(attachments: [Attachment]) {
        self.attachments = attachments
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostFilePreviewsCollectionViewCell", for: indexPath) as! PostFilesPreviewsCollectionViewCell
        cell.previewImage.kf.setImage(with: attachments[indexPath.row].thumbnailUrl, options: [.transition(.fade(0.2)), .processor(Constants.imageProcessor)])
        return cell
    }
}
