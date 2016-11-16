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
    var captchaResult: CaptchaResult?
}

class CaptchaResult {
    var key = ""
    var input = ""
}
