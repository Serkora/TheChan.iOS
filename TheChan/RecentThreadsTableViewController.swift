//
//  RecentThreadsTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 26.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import RealmSwift

class RecentThreadsTableViewController: UITableViewController {

    private var uiRealm: Realm!
    private var notificationToken: NotificationToken?
    
    private func getItems() -> Results<HistoryItem> {
        return uiRealm.objects(HistoryItem.self).sorted(byProperty: "lastVisit", ascending: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiRealm = RealmInstance.ui
        let tableView = self.tableView!
        
        notificationToken = getItems().addNotificationBlock { changes in
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                tableView.endUpdates()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
 
    }
    
    deinit {
        notificationToken?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uiRealm.objects(HistoryItem.self).count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentThreadTableViewCell", for: indexPath) as! RecentThreadTableViewCell
        let item = getItems()[indexPath.row]
        
        cell.boardIdLabel.text = item.board
        cell.threadNameLabel.text = item.name

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
