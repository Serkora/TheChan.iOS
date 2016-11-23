//
//  PostingData.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class PostingData {
    var boardId = ""
    var threadNumber = 0
    var text = ""
    var subject = ""
    var name = ""
    var email = ""
    var isOp = false
    var captchaResult: CaptchaResult?
    var attachments = [PostingAttachment]()
}

class PostingAttachment {
    var name = ""
    var mimeType = ""
    var data = Data()
}

class CaptchaResult {
    var key = ""
    var input = ""
}
