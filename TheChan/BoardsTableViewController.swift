//
//  BoardsTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class BoardsTableViewController: UITableViewController {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var groups = [BoardsGroup]()
    private let chanManager = ChanManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false         // this is done manually

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        startLoading(indicator: activityView)
        chanManager.currentChan.loadBoards { groups in
            if let groups = groups {
                self.groups = groups
                self.tableView.reloadData()
                self.stopLoading(indicator: self.activityView)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        let selection = tableView.indexPathForSelectedRow
        if (selection != nil) {
            tableView.deselectRow(at: selection!, animated: true)
            transitionCoordinator?.notifyWhenInteractionEnds { context in
                if (context.isCancelled) {
                    self.tableView.selectRow(at: selection, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section < groups.count ? groups[section].boards.count : 0;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardTableViewCell", for: indexPath) as! BoardTableViewCell

        let board = groups[indexPath.section].boards[indexPath.row]
        cell.idLabel.text = board.id
        cell.nameLabel.text = board.name

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenBoard" {
            let threadsTableViewController = segue.destination as! ThreadsTableViewController
            let selectedBoardPath = tableView.indexPathForSelectedRow!
            let selectedBoard = groups[selectedBoardPath.section].boards[selectedBoardPath.row]
            threadsTableViewController.board = selectedBoard
            threadsTableViewController.chan = chanManager.currentChan
        }
    }

}
