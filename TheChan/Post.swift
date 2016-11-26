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
    
    func getTitle() -> String {
        if !subject.isEmpty {
            return subject
        } else if !text.isEmpty {
            let offset = text.characters.count >= 50 ? 50 : text.characters.count
            let subject = text.substring(to: text.index(text.startIndex, offsetBy: offset))
            return String(htmlEncodedString: subject)
        } else {
            return "\(number)"
        }
    }
}
