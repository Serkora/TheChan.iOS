//
//  LocalizedStringWithFormat.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 27.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation

extension String {
    init(localizedFormat: String, argument: Any) {
        self = NSString.localizedStringWithFormat(NSLocalizedString(localizedFormat, comment: "") as NSString, argument as! CVarArg) as String
    }
}
