//
//  Facade.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import Alamofire

class Facade {
    static func loadBoards(onComplete: @escaping ([BoardsGroup]?) -> Void) {
        Alamofire.request("https://2ch.hk/makaba/mobile.fcgi?task=get_boards").responseJSON { response in
            if let rawGroups = response.result.value as? [String:[[String:AnyObject]]] {
                let groups = EntityMapper.map(groups: rawGroups)
                onComplete(groups)
            } else {
                onComplete(nil)
            }
        }
    }
    
    static func loadThreads(boardId: String, page: Int, onComplete: @escaping ([Thread]?) -> Void) {
        let pageStr = page == 0 ? "index" : String(page)
        Alamofire.request("https://2ch.hk/\(boardId)/\(pageStr).json").responseJSON { response in
            if let rawPage = response.result.value as? [String:AnyObject],
            let rawThreads = rawPage["threads"] as? [[String:AnyObject]]{
                let threads = EntityMapper.map(boardId: boardId, threads: rawThreads)
                onComplete(threads)
            } else {
                onComplete(nil)
            }
        }
    }
    
    static func loadThread(boardId: String, number: Int, from: Int = 0, onComplete: @escaping ([Post]?) -> Void) {
        let url = "https://2ch.hk/makaba/mobile.fcgi?task=get_thread&board=\(boardId)&thread=\(number)&post=\(from)"
        
        Alamofire.request(url).responseJSON { response in
            if let rawPosts = response.result.value as? [[String: AnyObject]] {
                let posts = rawPosts.map { post in EntityMapper.map(boardId: boardId, post: post) }
                onComplete(posts)
            } else {
                onComplete(nil)
            }
        }
    }
}

class EntityMapper {
    static func map(groups: [String: [[String: AnyObject]]]) -> [BoardsGroup] {
        return groups.map { name, boards -> BoardsGroup in
            let boards = boards.map { board in map(board: board) }
            return BoardsGroup(name: name, boards: boards)
        }
    }
    
    static func map(board: [String: AnyObject]) -> Board {
        return Board(id: board["id"] as! String, name: board["name"] as! String)
    }
    
    static func map(boardId: String, threads: [[String: AnyObject]]) -> [Thread] {
        return threads.map { thread in
            let result = Thread()
            result.omittedPosts = thread["posts_count"] as? Int ?? 0
            result.omittedFiles = thread["files_count"] as? Int ?? 0
            if let opPost = (thread["posts"] as? [[String: AnyObject]])?[0] {
                result.opPost = map(boardId: boardId, post: opPost)
            }
            
            return result
        }
    }
    
    static func map(boardId: String, post raw: [String: AnyObject]) -> Post {
        let post = Post()
        post.text = raw["comment"] as? String ?? ""
        post.subject = String(htmlEncodedString: raw["subject"] as? String ?? "")
        post.name = raw["name"] as? String ?? ""
        post.number = Int(raw["num"] as? String ?? "0")!
        
        if let files = raw["files"] as? [[String: AnyObject]] {
            post.attachments = files.map { file in map(boardId: boardId, attachment: file) }
        }
        
        let timestamp = (raw["timestamp"] as? NSNumber)?.int64Value ?? 0
        post.date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return post
    }
    
    static func map(boardId: String, attachment raw: [String: AnyObject]) -> Attachment {
        let url = "https://2ch.hk/\(boardId)/\(raw["path"] as? String ?? "")"
        let thumbUrl = "https://2ch.hk/\(boardId)/\(raw["thumbnail"] as? String ?? "")"
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
}
