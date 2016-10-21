//
//  UITableViewLoadingExtension.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 21.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

extension UITableViewController {
    func startLoading(indicator activityIndicator: UIActivityIndicatorView) {
        activityIndicator.startAnimating()
        let footer = self.tableView.tableFooterView!
        let frame: CGRect = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: footer.frame.size.width, height: 50)
        footer.frame = frame
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func stopLoading(indicator activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        let footer = self.tableView.tableFooterView!
        let frame: CGRect = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: footer.frame.size.width, height: 0)
        footer.frame = frame
        self.tableView.tableFooterView?.isHidden = true
    }
}
