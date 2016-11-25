//
//  FavoriteThreadsCollectionViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 12.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "FavoriteThreadCollectionViewCell"
private let minItemWidth = CGFloat(150.0)

class FavoriteThreadsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private var uiRealm: Realm? = nil
    private var notificationToken: NotificationToken? = nil
    private let chanManager = ChanManager()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        uiRealm = RealmInstance.ui
        
        // Do any additional setup after loading the view.
        guard let collectionView = self.collectionView else { return }
        notificationToken = uiRealm?.objects(FavoriteThread.self).addNotificationBlock { changes in
            switch changes {
            case .initial:
                collectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                }, completion: nil)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "OpenThread" {
            let chan = chanManager.currentChan
            guard let threadController = segue.destination as? ThreadTableViewController else { return }
            guard let cell = sender as? UICollectionViewCell else { return }
            guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
            guard let thread = uiRealm?.objects(FavoriteThread.self)[indexPath.item] else { return }
            threadController.info = (boardId: thread.board, threadNumber: thread.number)
            threadController.chan = chan
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uiRealm?.objects(FavoriteThread.self).count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoriteThreadCollectionViewCell
        guard let thread = uiRealm?.objects(FavoriteThread.self)[indexPath.row] else { return cell }
        
        cell.boardLabel.text = thread.board
        cell.threadNameLabel.text = thread.name
        cell.unreadPostsLabel.text = "\(thread.unreadPosts)"
        if thread.unreadPosts > 0 {
            cell.unreadPostsLabel.textColor = collectionView.tintColor
        }
        
        cell.thumbnailImageView.kf.setImage(with: URL(string: thread.thumbnailUrl))
    
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing
        let minItemWidthWithSpacing = spacing + minItemWidth
        let numberOfItemsCanFit = floor(availableWidth / minItemWidthWithSpacing)
        let itemWidth = (availableWidth - spacing * (numberOfItemsCanFit - 1)) / numberOfItemsCanFit
        return CGSize(width: itemWidth, height: 100)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        guard let realm = uiRealm else { return }
        
        let dispatchGroup = DispatchGroup()
        
        activityIndicator.startAnimating()
        sender.isEnabled = false
        
        for thread in realm.objects(FavoriteThread.self) {
            dispatchGroup.enter()
            update(thread: thread) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            sender.isEnabled = true
        }
    }
    
    func update(thread: FavoriteThread, onFinished: @escaping () -> Void) {
        guard let realm = uiRealm else { return }
        chanManager.currentChan.loadThread(boardId: thread.board, number: thread.number, from: thread.lastLoadedPost + 1) { posts in
            if let posts = posts {
                do {
                    try realm.write {
                        thread.lastLoadedPost += posts.count
                        thread.unreadPosts += posts.count
                    }
                } catch {}
            }
            
            onFinished()
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
