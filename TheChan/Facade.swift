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
                let threads = EntityMapper.map(threads: rawThreads)
                onComplete(threads)
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
    
    static func map(threads: [[String: AnyObject]]) -> [Thread] {
        return threads.map { thread in
            let result = Thread()
            result.omittedPosts = thread["posts_count"] as? Int ?? 0
            result.omittedFiles = thread["files_count"] as? Int ?? 0
            if let opPost = (thread["posts"] as? [[String: AnyObject]])?[0] {
                result.opPost = map(post: opPost)
            }
            
            return result
        }
    }
    
    static func map(post raw: [String:AnyObject]) -> Post {
        let post = Post()
        post.text = raw["comment"] as? String ?? ""
        post.name = raw["name"] as? String ?? ""
        let timestamp = (raw["timestamp"] as? NSNumber)?.int64Value ?? 0
        post.date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return post
    }
}
