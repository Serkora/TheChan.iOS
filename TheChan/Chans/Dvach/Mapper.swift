//
//  Mapper.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 25.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class DvachMapper {
    func map(groups: [String: [[String: AnyObject]]]) -> [BoardsGroup] {
        return groups.map { name, boards -> BoardsGroup in
            let boards = boards.map { board in map(board: board) }
            return BoardsGroup(name: name, boards: boards)
        }
    }
    
    func map(board: [String: AnyObject]) -> Board {
        return Board(id: board["id"] as! String, name: board["name"] as! String)
    }
    
    func map(threads: [[String: AnyObject]]) -> [Thread] {
        return threads.map { thread in
            let result = Thread()
            result.omittedPosts = thread["posts_count"] as? Int ?? 0
            result.omittedFiles = thread["files_count"] as? Int ?? 0
            var posts = (thread["posts"] as? [[String: AnyObject]] ?? []).map { post in map(post: post) }
            if posts.count > 0 {
                result.opPost = posts[0]
                posts.remove(at: 0)
                result.omittedPosts += posts.count
                result.omittedFiles += posts.reduce(0) { count, post in count + post.attachments.count }
            }
            
            return result
        }
    }
    
    func map(post raw: [String: AnyObject]) -> Post {
        let post = Post()
        post.text = raw["comment"] as? String ?? ""
        let markup = DvachMarkup(from: post.text)
        if markup != nil {
            post.attributedString = markup!.getAttributedString()
        }
        
        post.subject = String(htmlEncodedString: raw["subject"] as? String ?? "")
        post.name = raw["name"] as? String ?? ""
        post.number = Int(raw["num"] as? String ?? "0")!
        
        if let files = raw["files"] as? [[String: AnyObject]] {
            post.attachments = files.map { file in map(attachment: file) }
        }
        
        let timestamp = (raw["timestamp"] as? NSNumber)?.int64Value ?? 0
        post.date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return post
    }
    
    func map(attachment raw: [String: AnyObject]) -> Attachment {
        let url = "https://2ch.hk\(raw["path"] as? String ?? "")"
        let thumbUrl = "https://2ch.hk\(raw["thumbnail"] as? String ?? "")"
        let size = (
            raw["width"] as? Int ?? 0,
            raw["height"] as? Int ?? 0
        )
        
        let thSize = (
            raw["th_width"] as? Int ?? 0,
            raw["th_height"] as? Int ?? 0
        )
        
        let fileExt = url.components(separatedBy: ".").last ?? "png"
        var type = AttachmentType.image
        if fileExt == "webm" {
            type = .video
        }
        
        return Attachment(url: url, thumbUrl: thumbUrl, size: size, thumbSize: thSize, type: type)
    }

    func map(postingData post: PostingData) -> [String: String] {
        var dict: [String: String] = [
            "json": String(1),
            "task": "post",
            "board": post.boardId,
            "thread": String(post.threadNumber),
            "comment": post.text,
            "op_mark": post.isOp ? "1" : "0",
            "subject": post.subject,
            "email": post.email,
            "name": post.name
        ]
        
        if post.captchaResult != nil {
            dict["captcha_type"] = "2chaptcha"
            dict["2chaptcha_id"] = post.captchaResult!.key
            dict["2chaptcha_value"] = post.captchaResult!.input
        }
        
        return dict
    }

}
