//
//  BoardsGroup.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class BoardsGroup {
    init(name: String, boards: [Board] = []) {
        self.name = name
        self.boards = boards
    }
    
    var name: String
    var boards: [Board]
}
