//
//  RealmConfiguration.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import RealmSwift

class RealmInstance {
    
    private(set) static var ui: Realm!
    
    static func initialize() -> Bool {
        do {
            let realm = try Realm()
            self.ui = realm
        } catch {
            return false
        }
        
        return true
    }
}
