//
//  Chan.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 25.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import Alamofire

protocol Chan {
    var maxAttachments: Int { get }
    func loadBoards(onComplete: @escaping ([BoardsGroup]?) -> ())
    func loadThreads(boardId: String, page: Int, onComplete: @escaping ([Thread]?) -> ())
    func loadThread(boardId: String, number: Int, from: Int, onComplete: @escaping ([Post]?) -> ())
    func isCaptchaEnabled(in board: String, onComplete: @escaping (Bool) -> ())
    func getCaptcha(onComplete: @escaping (Captcha?) -> ())
    func send(post: PostingData, onComplete: @escaping (Bool, String?, Int?) -> ())
}

extension Chan {
    func getAndMapDictionary<T>(_ url: String, mapping: @escaping ([String: AnyObject]) -> T?, onComplete: @escaping (T?) -> ()) {
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value as? [String: AnyObject] {
                onComplete(mapping(result))
            } else {
                onComplete(nil)
            }
        }
    }
    
    func getAndMapList<T, RawListType>(_ url: String, mapping: @escaping ([RawListType]) -> T?, onComplete: @escaping (T?) -> ()) {
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value as? [RawListType] {
                onComplete(mapping(result))
            } else {
                onComplete(nil)
            }
        }
    }
}
