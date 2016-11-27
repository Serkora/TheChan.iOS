//
//  RepliesMapFormer.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 27.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class RepliesMapFormer {
    func createMapFrom(newPosts: [Post], existingMap: [Int: [Post]]) -> [Int: [Post]] {
        let quotedPosts = findQuotedPostsIn(posts: newPosts) // [PostNumber: Replies]
        var repliesMap = existingMap
        for (number, replies) in quotedPosts {
            if repliesMap[number] != nil { // If we have some replies to this post
                repliesMap[number]! += replies // Just add new replies
            } else {
                repliesMap[number] = replies
            }
        }
        
        return repliesMap
    }
    
    private func findQuotedPostsIn(posts: [Post]) -> [Int: [Post]] {
        guard let regex =  try? NSRegularExpression(pattern: ">>(\\d+)", options: .caseInsensitive) else { return [:] }
        var map = [Int: [Post]]()
        for post in posts {
            let text = post.text as NSString
            let matches = regex.matches(in: post.text, options: [], range: NSMakeRange(0, post.text.characters.count))
            for match in matches {
                let matchRange = match.rangeAt(1)
                let number = Int(text.substring(with: matchRange)) ?? 0
                if map[number] != nil {
                    map[number]!.append(post)
                } else {
                    map[number] = [post]
                }
            }
        }
        
        return map
    }
}
