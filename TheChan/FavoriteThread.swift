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
}
