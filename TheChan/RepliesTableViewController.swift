//
//  RepliesTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 27.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class RepliesTableViewController: UITableViewController, PostTableViewCellDelegate, UIGestureRecognizerDelegate {
    
    var allReplies = [Int: [Post]]()
    var postsStack = [[Post]]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        tableView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return postsStack.last?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        addGestureRecognizer(to: cell)
        guard let post = postsStack.last?[indexPath.section] else { return cell }
        cell.post = post
        
        cell.subjectLabel.text = post.subject
        cell.subjectLabel.isHidden = post.subject.isEmpty
        
        cell.positionLabel.text = String(indexPath.row + 1)
        cell.nameLabel.text = post.name
        cell.numberLabel.text = String(post.number)
        cell.dateLabel.text = dateFormatter.string(from: post.date)
        cell.postContentView.attributedText = post.attributedString
        cell.filesPreviewsCollectionView.isHidden = post.attachments.count == 0
        cell.attachments = post.attachments
//        cell.onAttachmentSelected = onAttachmentSelected
        
        cell.filesPreviewsCollectionView.dataSource = cell
        cell.filesPreviewsCollectionView.delegate = cell
        cell.filesPreviewsCollectionView.reloadData()
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.borderWidth = 8.0
        cell.isOpaque = true
        
        let repliesCount = allReplies[post.number]?.count ?? 0
        cell.repliesButton.isHidden = repliesCount == 0
        let title = String(localizedFormat: "%d replies", argument: repliesCount)
        cell.repliesButton.setTitle(title, for: .normal)
        cell.bottomMarginConstraint.constant = repliesCount == 0 ? 8.0 : 0.0
        
        cell.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20)
        
        cell.delegate = self

        return cell
    }
    
    func repliesButtonTapped(sender: PostTableViewCell) {
        let number = sender.post.number
        let replies = allReplies[number]!
        postsStack.append(replies)
        tableView.reloadData()
    }
    
    func addGestureRecognizer(to view: UIView) {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        view.addGestureRecognizer(recognizer)
        recognizer.delegate = self
    }
    
    func panGesture(_ sender: UIPanGestureRecognizer) {
        guard let sourceCell = sender.view as? PostTableViewCell else { return }
        guard let sourceRow = tableView.indexPath(for: sourceCell)?.section else { return }
        guard let visibleRows = tableView.indexPathsForVisibleRows?.map({ $0.section }) else { return }
        let xOffset = sender.translation(in: sourceCell).x
        for row in visibleRows {
            let distance = CGFloat(abs(sourceRow - row))
            let movingThreshold = distance * 50
            let offsetModification = abs(xOffset) < movingThreshold ? -abs(xOffset) : -movingThreshold
            let offset = xOffset > 0 ? xOffset + offsetModification : xOffset - offsetModification
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: row)) else { continue }
            cell.frame.origin.x = offset
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: view)
            return fabs(velocity.y) < fabs(velocity.x)
        }
        
        return true
        
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
