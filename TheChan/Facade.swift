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
}
