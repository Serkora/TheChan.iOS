//
//  HistoryItem.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 26.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryItem: Object {
    dynamic var board = ""
    dynamic var number = 0
    dynamic var name = ""
    dynamic var lastVisit = Date()
}
