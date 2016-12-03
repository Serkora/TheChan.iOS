//
//  DvachChan.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 25.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import Alamofire

class Dvach: Chan {
    
    private let mapper = DvachMapper()
    var maxAttachments: Int { return 4 }
    let publicKey = ""
    var salt = ""
    var privateKey = ""
    
    init() {
        
    }
    
    func loadBoards(onComplete: @escaping ([BoardsGroup]?) -> ()) {
        getAndMapDictionary("https://2ch.hk/makaba/mobile.fcgi?task=get_boards", mapping: { (groups) -> [BoardsGroup]? in
            self.mapper.map(groups: groups as? [String : [[String : AnyObject]]] ?? [:]) }, onComplete: onComplete)
    }
    
    func loadThreads(boardId: String, page: Int, onComplete: @escaping ([Thread]?) -> ()) {
        let pageStr = page == 0 ? "index" : String(page)
        getAndMapDictionary("https://2ch.hk/\(boardId)/\(pageStr).json", mapping: { (page) -> [Thread]? in
            if let rawThreads = page["threads"] as? [[String:AnyObject]] {
                return self.mapper.map(threads: rawThreads)
            }
            
            return nil
        }, onComplete: onComplete)
    }
    
    func loadThread(boardId: String, number: Int, from: Int, onComplete: @escaping ([Post]?) -> ()) {
        let url = "https://2ch.hk/makaba/mobile.fcgi?task=get_thread&board=\(boardId)&thread=\(number)&post=\(from)"
        getAndMapList(
            url,
            mapping: {
                (posts: ([[String: AnyObject]])) -> [Post]? in posts.map { self.mapper.map(post: $0) }
            },
            onComplete: onComplete)
    }
    
    func isCaptchaEnabled(in board: String, onComplete: @escaping (Bool) -> ()) {
        getAndMapDictionary(
            "https://2ch.hk/api/captcha/settings/\(board)",
            mapping: { $0["enabled"] as? Bool }) {
                onComplete($0 ?? true)
        }
    }
    
    func getCaptcha(onComplete: @escaping (Captcha?) -> ()) {
        getAndMapDictionary("https://2ch.hk/api/captcha/2chaptcha/service_id", mapping: { result in
            guard let key = result["id"] else { return nil }
            let url = URL(string: "https://2ch.hk/api/captcha/2chaptcha/image/\(key)")
            let captcha = ImageCaptcha()
            captcha.key = key as? String ?? ""
            captcha.imageURL = url
            
            return captcha
        }, onComplete: onComplete)
    }
    
    func send(post: PostingData, onComplete: @escaping (Bool, String?, Int?) -> ()) {
        let data = mapper.map(postingData: post)
        let url = "https://2ch.hk/makaba/posting.fcgi"
        Alamofire.upload(multipartFormData: { formData in
            for (key, value) in data {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            
            for (index, attachment) in post.attachments.enumerated() {
                formData.append(attachment.data, withName: "image\(index)", fileName: attachment.name, mimeType: attachment.mimeType)
            }
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let request, _, _):
                request.responseJSON { response in
                    if let result = response.result.value as? [String: Any] {
                        let error = result["Reason"] as? String
                        let num = result["Num"] as? Int ?? result["Target"] as? Int
                        if error != nil {
                            onComplete(false, error, nil)
                        } else {
                            onComplete(true, nil, num)
                        }
                    } else {
                        onComplete(false, String(response.response?.statusCode ?? 404), nil)
                    }
                }
            default:
                onComplete(false, nil, nil)
            }
        }
    }
}
