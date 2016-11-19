//
//  ThreadTableViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 16.10.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import MWPhotoBrowser
import RealmSwift
import OGVKit

class ThreadTableViewController: UITableViewController, MWPhotoBrowserDelegate {
    
    private enum ThreadRefreshingResult {
        case success, failure
    }
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var info: (boardId: String, threadNumber: Int) = ("", 0)
    var posts = [Post]()
    let dateFormatter = DateFormatter()
    
    private var unreadPosts = 0
    private var allFiles = [MWPhoto]()
    private var allAttachments = [Attachment]()
    private let stateController = ThreadStateViewController()
    private let uiRealm: Realm = RealmInstance.ui
    private var favoriteThread: FavoriteThread? = nil
    
    private var isInFavorites = false {
        didSet {
            favoriteButton.image = isInFavorites ? #imageLiteral(resourceName: "favoriteIconFilled") : #imageLiteral(resourceName: "favoriteIconBordered")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        tableView.allowsSelection = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        configureStateController()
        configureFavoritesState()
        
        self.titleButton.setTitle(self.getTitleFrom(boardId: info.boardId, threadNumber: info.threadNumber), for: .normal)
        startLoading(indicator: progressIndicator)
        Facade.loadThread(boardId: info.boardId, number: info.threadNumber) { posts in
            if let posts = posts {
                self.titleButton.setTitle(self.getTitleFrom(post: posts.first!), for: .normal)
                self.posts += posts
                self.updateFavoriteState(initialLoad: true)
                self.updateThreadState(refreshingResult: .success)
            }
            
            self.stopLoading(indicator: self.progressIndicator)
            self.tableView.reloadData()
        }
    }
    
    func configureStateController() {
        guard let toolbar = navigationController?.toolbar else { return }
        guard let stateView = stateController.view else { return }
        
        for view in toolbar.subviews {
            view.removeFromSuperview()
        }
        
        stateController.primaryState = getUnreadPostsString()
        stateController.secondaryState = NSLocalizedString("THREAD_LAST_UPDATE", comment: "Last update time") + "14:88"
        
        toolbar.addSubview(stateView)
        
        stateView.center.y = toolbar.frame.size.height / 2
        stateView.center.x += 10
    }
    
    func configureFavoritesState() {
        let favoriteThread = uiRealm.objects(FavoriteThread.self).filter("board == %@ AND number == %@", info.boardId, info.threadNumber).first
        if favoriteThread != nil {
            self.favoriteThread = favoriteThread
        }
        
        isInFavorites = favoriteThread != nil
    }
    
    func updateFavoriteState(initialLoad: Bool) {
        guard let thread = favoriteThread else { return }
        let newLastLoadedPosts = posts.count
        var newLastReadedPost = 0
        if initialLoad {
            if posts.count > thread.lastReadedPost {
                unreadPosts = posts.count - thread.lastReadedPost
                newLastReadedPost = posts.count - unreadPosts
            } else {
                unreadPosts = 0
                newLastReadedPost = posts.count
            }
        } else {
            newLastReadedPost = posts.count - unreadPosts
        }
        
        do {
            try uiRealm.write {
                thread.unreadPosts = unreadPosts
                thread.lastReadedPost = newLastReadedPost
                thread.lastLoadedPost = newLastLoadedPosts
            }
        } catch {}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func getTitleFrom(post: Post) -> String {
        if post.subject.isEmpty {
            let offset = post.text.characters.count >= 50 ? 50 : post.text.characters.count
            let subject = post.text.substring(to: post.text.index(post.text.startIndex, offsetBy: offset))
            return String(htmlEncodedString: subject)
        }
        
        return post.subject
    }
    
    func getTitleFrom(boardId: String, threadNumber: Int) -> String {
        return "/\(boardId)/ - \(threadNumber)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setToolbarHidden(true, animated: true)
    }

    func loadPosts(from: Int, onComplete: @escaping ([Post]?) -> Void) {
        Facade.loadThread(boardId: info.boardId, number: info.threadNumber, from: from) { posts in
            onComplete(posts)
        }
    }
    
    func refresh() {
        loadPosts(from: posts.count + 1) { newPosts in
            guard let posts = newPosts else {
                self.updateThreadState(refreshingResult: .failure)
                return
            }
            
            self.posts += posts
            self.unreadPosts += posts.count
            self.updateThreadState(refreshingResult: .success)
            self.updateFavoriteState(initialLoad: false)
            self.tableView.reloadData()
        }
    }
    
    @IBAction private func refreshButtonTapped(_ sender: UIBarButtonItem) {
        stateController.startLoading(with: NSLocalizedString("THREAD_REFRESHING", comment: "Refreshing"))
        refresh()
    }
    
    private func updateThreadState(refreshingResult: ThreadRefreshingResult) {
        switch refreshingResult {
        case .failure:
            stateController.endLoading(with: "Error") // TODO: Localize
        default:
            stateController.endLoading(with: getUnreadPostsString())
        }
    }
    
    private func getUnreadPostsString() -> String {
        return NSString.localizedStringWithFormat(
            NSLocalizedString("%d new posts", comment: "Count of new posts") as NSString, unreadPosts)
            as String
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
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        
        cell.subjectLabel.text = post.subject
        if post.subject.isEmpty {
            cell.subjectLabel.isHidden = true
        }
        
        cell.positionLabel.text = String(indexPath.row + 1)
        cell.nameLabel.text = post.name
        cell.numberLabel.text = String(post.number)
        cell.dateLabel.text = dateFormatter.string(from: post.date)
        cell.postContentView.attributedText = post.attributedString
        cell.filesPreviewsCollectionView.isHidden = post.attachments.count == 0
        cell.attachments = post.attachments
        cell.onAttachmentSelected = onAttachmentSelected
        
        cell.filesPreviewsCollectionView.dataSource = cell
        cell.filesPreviewsCollectionView.delegate = cell
        cell.filesPreviewsCollectionView.reloadData()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PostTableViewCell
        let index = indexPath.row
        if index == posts.count - unreadPosts {
            cell.backgroundColor = UIColor(red: 255/255.0, green: 149/255.0, blue: 0.0, alpha: 0.2)
        }
    }
    
    func onAttachmentSelected(attachment: Attachment) {
        if (attachment.type == .video){
            let videoController = WebmViewController(url: attachment.url)
//            videoController.setVideo(attachment.url)

            self.navigationController!.pushViewController(videoController, animated: true)
            return
        }
        
        allAttachments = posts.flatMap { post in post.attachments }
        allFiles = allAttachments.map { attachment in
            attachment.type == .image ? MWPhoto(url: attachment.url) : MWPhoto(videoURL: attachment.url)
        }
        
        let browser = MWPhotoBrowser(delegate: self)!
        browser.setCurrentPhotoIndex(UInt(allAttachments.index(of: attachment)!))
        browser.displayNavArrows = true
        navigationController?.pushViewController(browser, animated: true)
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(allFiles.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return allFiles[Int(index)]
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
        if segue.identifier == "Reply" {
            guard let controller = segue.destination as? PostingViewController else { return }
            controller.boardId = info.boardId
            controller.mode = .reply(threadNumber: info.threadNumber)
        }
    }

    @IBAction func titleTouched(_ sender: AnyObject) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @IBAction func goDownButtonTapped(_ sender: Any) {
        let indexPath = IndexPath(row: posts.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
         do {
            try uiRealm.write {
                if isInFavorites {
                    uiRealm.delete(uiRealm.objects(FavoriteThread.self).filter("board == %@ AND number == %@", info.boardId, info.threadNumber))
                    
                    isInFavorites = !isInFavorites
                } else if posts.count > 0 {
                    uiRealm.add(FavoriteThread.create(boardId: info.boardId, threadNumber: info.threadNumber, opPost: posts.first!, postsCount: posts.count))
                    
                    isInFavorites = !isInFavorites
                }
            }
        } catch {}
    }
    
    @IBAction func unwindToThread(segue: UIStoryboardSegue) {
        if segue.source is PostingViewController {
            refresh()
        }
    }
}
