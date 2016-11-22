//
//  ThreadsTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 13.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

class ThreadsTableViewController: UITableViewController {

    private var threads = [Thread]()
    private var currentPage = 0
    private var isLoading = false
    private var imageProcessor = RoundCornerImageProcessor(cornerRadius: 10)
    private var isRefreshing = false
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var board: Board = Board(id: "board", name: "Undefined board") {
        didSet {
            self.titleButton.setTitle("/\(board.id)/ - \(board.name)", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false         // this is done manually
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        
        refreshControl?.addTarget(self, action: #selector(ThreadsTableViewController.refresh(refreshControl:)), for: .valueChanged)
        
        loadPage(currentPage)
        
        NSLog("threads controller loaded")
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        let selection = tableView.indexPathForSelectedRow
        if (selection != nil) {
            tableView.deselectRow(at: selection!, animated: true)
            transitionCoordinator?.notifyWhenInteractionEnds { context in
                if (context.isCancelled) {
                    self.tableView.selectRow(at: selection, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.hidesBackButton = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        if isLoading { return }
        isRefreshing = true
        
        threads.removeAll()
        tableView.reloadData()
        currentPage = 0
        loadPage(currentPage) {
            refreshControl.endRefreshing()
            self.isRefreshing = false
        }
    }
    
    func loadPage(_ number: Int, completed: @escaping () -> Void = {}) {
        self.isLoading = true
        
        if !isRefreshing {
            self.startLoading(indicator: activityIndicator)
        }
        
        NSLog("starting to load threads?")
        Facade.loadThreads(boardId: board.id, page: number) { threads in
            NSLog("Some response received?")
            if let threads = threads {
                NSLog("have threads?")
                self.updateThreads(threads)
                NSLog("reloading data?")
                self.tableView.reloadData()
            }
            
            self.stopLoading(indicator: self.activityIndicator)
            self.isLoading = false
            completed()
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
        NSLog("returning %d threadcount", threads.count)
        return threads.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadTableViewCell", for: indexPath) as! ThreadTableViewCell

        let thread = threads[indexPath.row]
        cell.numberLabel.text = String(thread.opPost.number)
        cell.subjectLabel.text = thread.opPost.subject
//        cell.postTextLabel.attributedText = thread.opPost.attributedString
        cell.postTextView.textContainer.maximumNumberOfLines = 7
        cell.postTextView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.postTextView.attributedText = thread.opPost.attributedString
        cell.nameLabel.text = thread.opPost.name
        cell.omittedPostsLabel.text = String(thread.omittedPosts)
        cell.omittedPostsNounLabel.text = NSString.localizedStringWithFormat(
            NSLocalizedString("%d posts", comment: "") as NSString, thread.omittedPosts) as String
        cell.omittedFilesLabel.text = String(thread.omittedFiles)
        cell.omittedFilesNounLabel.text = NSString.localizedStringWithFormat(
            NSLocalizedString("%d files", comment: "") as NSString, thread.omittedFiles) as String
        
        if thread.opPost.attachments.count > 0 {
            let firstImage = thread.opPost.attachments[0].thumbnailUrl
            cell.opPostImageView.kf.setImage(with: firstImage, options: [.transition(.fade(0.2)), .processor(imageProcessor)])
        } else {
            cell.imageWidthConstraint.constant = 0
            cell.imageHorizontalSpacingConstraint.constant = 0
            cell.imageVerticalSpacingConstraint.constant = 0
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.dateLabel.text = formatter.string(from: thread.opPost.date)
        
        cell.layoutIfNeeded()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! ThreadTableViewCell
        if indexPath.row >= threads.count {
            return
        }
        
        let thread = threads[indexPath.row]
        
        if thread.opPost.attachments.count > 0 {
            cell.opPostImageView.kf.cancelDownloadTask()
        }
    }
    
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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenThread" {
            let threadView = segue.destination as! ThreadTableViewController
            let thread = threads[tableView.indexPathForSelectedRow!.row]
            threadView.info = (boardId: board.id, threadNumber: thread.opPost.number)
        }
    }

    @IBAction func titleTouched(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
