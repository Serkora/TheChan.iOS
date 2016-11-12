//
//  FavoriteThread.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 11.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteThread: Object {
    dynamic var board = ""
    dynamic var number = 0
    dynamic var name = ""
    dynamic var unreadPosts = 0
    dynamic var lastLoadedPost = 0
    dynamic var lastReadedPost = 0
    dynamic var thumbnailUrl = ""
    
    private static func getNameFrom(post: Post) -> String {
        if post.subject.isEmpty {
            let offset = post.text.characters.count >= 50 ? 50 : post.text.characters.count
            let subject = post.text.substring(to: post.text.index(post.text.startIndex, offsetBy: offset))
            return String(htmlEncodedString: subject)
        }
        
        return post.subject
    }

    
    static func create(boardId: String, threadNumber: Int, opPost: Post, postsCount: Int) -> FavoriteThread {
        let thread = FavoriteThread()
        thread.board = boardId
        thread.number = threadNumber
        thread.name = getNameFrom(post: opPost)
        thread.lastLoadedPost = postsCount
        thread.lastReadedPost = postsCount
        if opPost.attachments.count > 0 {
            thread.thumbnailUrl = opPost.attachments[0].thumbnailUrl.absoluteString
        }
        
        return thread
    }
}
