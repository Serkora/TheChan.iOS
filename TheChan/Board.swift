//
//  Board.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

class Board {
    init(id: String, name: String) {
        self.name = name
        self.id = id
    }
    
    var description: String {
        return "Board(\(id), '\(name)')"
    }
    
    var id: String
    var name: String
    
}
