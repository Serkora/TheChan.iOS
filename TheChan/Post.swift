//
//  Post.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 14.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class Post {
    var name = ""
    var subject = ""
    var number = 0
    var parent = 0
    var trip = ""
    var date = Date()
    var text = ""
    var attributedString = NSAttributedString()
    var attachments = [Attachment]()
    var repliedTo = [Int]()
    var replies = [Int]()
}
