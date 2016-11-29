//
//  HTMLEntities.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 14.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Fuzi

extension String {
    init(htmlEncodedString: String) {
        self.init()
        let document = try! HTMLDocument(string: htmlEncodedString, encoding: .utf8)
        let text = document.body?.stringValue ?? htmlEncodedString
        self = text
    }
}
