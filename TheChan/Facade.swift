//
//  Facade.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

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
                let posts = rawPosts.map { post in EntityMapper.map(post: post) }
                onComplete(posts)
            } else {
                onComplete(nil)
            }
        }
    }
    
    static func isCaptchaEnabled(in board: String, onComplete: @escaping (Bool) -> Void) {
        let url = "https://2ch.hk/api/captcha/settings/\(board)"
        Alamofire.request(url).responseJSON { response in
            guard let result = response.result.value as? [String: AnyObject] else { onComplete(true); return }
            let isEnabled = result["enabled"] as? Bool ?? true
            onComplete(isEnabled)
        }
    }
    
    static func getCaptcha(onComplete: @escaping (Captcha?) -> Void) {
        let url = "https://2ch.hk/api/captcha/2chaptcha/service_id"
        Alamofire.request(url).responseJSON { response in
            guard let result = response.result.value as? [String: AnyObject] else { onComplete(nil); return }
            guard let key = result["id"] else { onComplete(nil); return }
            let url = URL(string: "https://2ch.hk/api/captcha/2chaptcha/image/\(key)")
            let captcha = ImageCaptcha()
            captcha.key = key as? String ?? ""
            captcha.imageURL = url
            onComplete(captcha)
        }
    }
    
    static func send(post: PostingData, onComplete: @escaping (Bool) -> Void) {
        let data = EntityMapper.map(postingData: post)
        let url = "https://2ch.hk/makaba/posting.fcgi"
        Alamofire.upload(multipartFormData: { formData in
            for (key, value) in data {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let request, _, _):
                request.responseJSON { response in
                    if let result = response.result.value as? [String: Any] {
                        onComplete(true)
                    }
                }
            default:
                onComplete(false)
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
                result.opPost = map(post: opPost)
            }
            
            return result
        }
    }
    
    static func map(post raw: [String: AnyObject]) -> Post {
        let post = Post()
        post.text = raw["comment"] as? String ?? ""
        let markup = Markup(from: post.text)
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
    
    static func map(attachment raw: [String: AnyObject]) -> Attachment {
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
    
    static func map(postingData post: PostingData) -> [String: String] {
        var dict: [String: String] = [
            "json": String(1),
            "task": "post",
            "board": post.boardId,
            "thread": String(post.threadNumber),
            "comment": post.text
        ]
        
        if post.captchaResult != nil {
            dict["captcha_type"] = "2chaptcha"
            dict["2chaptcha_id"] = post.captchaResult!.key
            dict["2chaptcha_value"] = post.captchaResult!.input
        }
        
        return dict
    }
}

class Markup {
    
    private struct Node {
        let offset: Int
        let name: String
        let innerText: String
        let rawNode: XMLElement
        
        init(name: String, offset: Int, innerText: String, rawNode: XMLElement) {
            self.offset = offset
            self.name = name
            self.innerText = innerText
            self.rawNode = rawNode
        }
        
        subscript(attribute: String) -> String? {
            get {
                return rawNode[attribute]
            }
        }
    }

    
    var fontSize = CGFloat(15)
    var smallFontSize = CGFloat(11)
    let html: String
    private let document: HTMLDocument
    
    init?(from html: String) {
        self.html = html.replacingOccurrences(of: "<br>", with: "\n")
        guard let document = HTML(html: self.html, encoding: .utf8) else { return nil }
        self.document = document
    }
    
    private func walk(callback: (Node) -> Void) {
        var textOffset = 0
        guard let body = document.body else { return }
        for node in body.xpath("/*//.") {
            let nodeName = node.tagName ?? ""
            let nodeText = node.text ?? ""
            
            if nodeName == "text" {
                textOffset += nodeText.characters.count
                continue
            }
            
            let resultNode = Node(name: nodeName, offset: textOffset, innerText: nodeText, rawNode: node)
            callback(resultNode)
        }
    }
    
    private func getAttributesFrom(node: Node) -> [String: Any]? {
        if node.name == "strong" {
            return [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
        }
        
        if node.name == "em" {
            return [NSFontAttributeName: UIFont.italicSystemFont(ofSize: fontSize)]
        }
        
        let nodeClass = node["class"]
        
        if nodeClass == "spoiler" {
            return [
                NSBackgroundColorAttributeName: UIColor.lightGray,
                NSForegroundColorAttributeName: UIColor.black
            ]
        }
        
        if nodeClass == "unkfunc" {
            return [NSForegroundColorAttributeName: UIColor(red: 76 / 255.0, green: 217 /  255.0, blue: 100 / 255.0, alpha: 1.0)]
        }
        
        if node.name == "sub" {
            return [
                NSBaselineOffsetAttributeName: CGFloat(-2),
                NSFontAttributeName: UIFont.systemFont(ofSize: smallFontSize)
            ]
        }
        
        if node.name == "sup" {
            return [
                NSBaselineOffsetAttributeName: CGFloat(5),
                NSFontAttributeName: UIFont.systemFont(ofSize: smallFontSize)
            ]
        }
        
        if node.name == "a" {
            return [
                NSLinkAttributeName: "link",
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
            ]
        }
        
        return nil
    }
    
    private func render(nodes: [Node], to attributedString: NSMutableAttributedString) {
        for node in nodes {
            let attributes = getAttributesFrom(node: node)
            if attributes == nil {
                continue
            }
            
            let length = node.innerText.characters.count
            attributedString.addAttributes(attributes!, range: NSRange(location: node.offset, length: length))
        }
    }
    
    func getAttributedString() -> NSAttributedString {
        var fullText = ""
        var nodes = [Node]()
        walk { node in
            if node.name == "body" {
                fullText = node.innerText
            } else if node.name != "html" {
                nodes.append(node)
            }
        }
        
        let resultAttributedString = NSMutableAttributedString(string: fullText, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.white
        ])
        
        render(nodes: nodes, to: resultAttributedString)
        return resultAttributedString
    }
}
