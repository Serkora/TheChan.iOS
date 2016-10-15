//
//  ThreadsTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 13.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class ThreadsTableViewController: UITableViewController {

    private var threads = [Thread]()
    private var currentPage = 0
    private var isLoading = false {
        didSet {
            
        }
    }
    
    var board: Board = Board(id: "board", name: "Undefined board") {
        didSet {
            self.title = "/\(board.id)/ - \(board.name)"
            self.currentPage = 0
            self.loadPage(currentPage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    func loadPage(_ number: Int) {
        self.isLoading = true
        Facade.loadThreads(boardId: board.id, page: number) { threads in
            if let threads = threads {
                self.updateThreads(threads)
                self.tableView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    func updateThreads(_ threads: [Thread]) {
        var newThreads = [Thread]()
        for thread in threads {
            let existingThread = self.threads.first { $0.opPost.number == thread.opPost.number }
            if existingThread != nil {
                existingThread!.omittedPosts = thread.omittedPosts
                existingThread!.omittedFiles = thread.omittedFiles
            } else {
                newThreads.append(thread)
            }
        }
        
        self.threads += newThreads
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
        return threads.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadTableViewCell", for: indexPath) as! ThreadTableViewCell

        let thread = threads[indexPath.row]
        cell.numberLabel.text = String(thread.opPost.number)
        cell.subjectLabel.text = thread.opPost.subject
        cell.postTextLabel.text = thread.opPost.text
        cell.nameLabel.text = thread.opPost.name

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let nextPage = self.threads.count - 5
//        if indexPath.row == nextPage && !self.isLoading {
//            self.isLoading = true
//            currentPage += 1
//            loadPage(currentPage)
//        }
//    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && !self.isLoading {
            currentPage += 1
            loadPage(currentPage)
        }
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
