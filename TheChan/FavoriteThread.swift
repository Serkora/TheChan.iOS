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
    dynamic var thumbnailUrl = ""

    
    static func create(boardId: String, threadNumber: Int, opPost: Post, postsCount: Int, unreadPosts: Int) -> FavoriteThread {
        let thread = FavoriteThread()
        thread.board = boardId
        thread.number = threadNumber
        thread.name = opPost.getTitle()
        thread.lastLoadedPost = postsCount
        thread.unreadPosts = unreadPosts
        if opPost.attachments.count > 0 {
            thread.thumbnailUrl = opPost.attachments[0].thumbnailUrl.absoluteString
        }
        
        return thread
    }
}
