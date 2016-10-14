//
//  Attachment.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 14.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

enum AttachmentType {
    case image, video
}

class Attachment {
    
    init(url: URL, thumbUrl: URL, size: (Int, Int), thumbSize: (Int, Int), type: AttachmentType) {
        self.url = url
        self.thumbnailUrl = thumbUrl
        self.size = size
        self.thumbnailSize = thumbSize
        self.type = type
    }
    
    var url: URL
    var thumbnailUrl: URL
    var size: (Int, Int)
    var thumbnailSize: (Int, Int)
    var type: AttachmentType
}
