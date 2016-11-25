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

class ThreadTableViewController: UITableViewController, MWPhotoBrowserDelegate, UIGestureRecognizerDelegate {
    
    private enum ThreadRefreshingResult {
        case success, failure
    }
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var info: (boardId: String, threadNumber: Int) = ("", 0)
    var posts = [Post]()
    let dateFormatter = DateFormatter()
    lazy var chan: Chan! = nil
    
    private var unreadPosts = 0
    private var allFiles = [MWPhoto]()
    private var allAttachments = [Attachment]()
    private let stateController = ThreadStateViewController()
    private let uiRealm: Realm = RealmInstance.ui
    private var favoriteThread: FavoriteThread? = nil
    
    private var isLoading = false
    private var needsScrollToBottom = false
    private var gestureRecognizerDelegate: UIGestureRecognizerDelegate!
    
    private var isInFavorites = false {
        didSet {
            favoriteButton.image = isInFavorites ? #imageLiteral(resourceName: "favoriteIconFilled") : #imageLiteral(resourceName: "favoriteIconBordered")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return (navigationController?.isNavigationBarHidden)!
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
        isLoading = true
        chan.loadThread(boardId: info.boardId, number: info.threadNumber, from: 0) { posts in
            if let posts = posts {
                self.titleButton.setTitle(self.getTitleFrom(post: posts.first!), for: .normal)
                self.posts += posts
                self.updateFavoriteState(initialLoad: true)
                self.updateThreadState(refreshingResult: .success)
            }
            
            self.isLoading = false
            self.stopLoading(indicator: self.progressIndicator)
            self.tableView.reloadData()
            
            if self.needsScrollToBottom {
                self.scrollToBottom()
            }
            self.needsScrollToBottom = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gestureRecognizerDelegate = navigationController!.interactivePopGestureRecognizer!.delegate!
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.setToolbarHidden(false, animated: false)
        navigationItem.setHidesBackButton(false, animated: true)
        fixStatusBarScroll(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = gestureRecognizerDelegate
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setToolbarHidden(true, animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationItem.hidesBackButton = false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !isLoading && navigationController!.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        return !isLoading
    }

    
    func fixStatusBarScroll(view: UIView){
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.scrollsToTop = false
            }
            if subview.subviews.count > 0 {
                fixStatusBarScroll(view: subview)
            }
        }
        self.tableView.scrollsToTop = true
    }
    
    func configureStateController() {
        guard let toolbar = navigationController?.toolbar else { return }
        guard let stateView = stateController.view else { return }
        
        for view in toolbar.subviews {
            view.removeFromSuperview()
        }
        
        stateController.primaryState = getUnreadPostsString()
        setLastRefreshTime()
        
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
        let lastReadPost = thread.lastLoadedPost - thread.unreadPosts
        if initialLoad {
            if posts.count > lastReadPost {
                unreadPosts = posts.count - lastReadPost
            } else {
                unreadPosts = 0
            }
        }
        
        do {
            try uiRealm.write {
                thread.unreadPosts = unreadPosts
                thread.lastLoadedPost = newLastLoadedPosts
            }
        } catch {}
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

    func loadPosts(from: Int, onComplete: @escaping ([Post]?) -> Void) {
        chan.loadThread(boardId: info.boardId, number: info.threadNumber, from: from) { posts in
            onComplete(posts)
        }
    }
    
    func refresh() {
        loadPosts(from: posts.count + 1) { newPosts in
            guard let posts = newPosts else {
                self.updateThreadState(refreshingResult: .failure)
                return
            }
            
            self.updateUnreadPostsState()
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
    
    private func updateUnreadPostsState() {
        guard let pathsForVisibleRows = tableView.indexPathsForVisibleRows else { return }
        guard let lastVisibleRow = pathsForVisibleRows.last else { return }
        if lastVisibleRow.row >= posts.count - unreadPosts {
            unreadPosts = 0
        }
    }
    
    private func updateThreadState(refreshingResult: ThreadRefreshingResult) {
        switch refreshingResult {
        case .failure:
            stateController.endLoading(with: "Error") // TODO: Localize
        default:
            stateController.endLoading(with: getUnreadPostsString())
        }
        
        setLastRefreshTime()
    }
    
    private func setLastRefreshTime() {
        let time = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: time)
        stateController.secondaryState = NSLocalizedString("THREAD_LAST_UPDATE", comment: "Last update time") + timeString
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
        cell.subjectLabel.isHidden = post.subject.isEmpty
        
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
        
        for view in cell.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.scrollsToTop = false
            }
        }
        
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
        if attachment.type == .video {
            let videoController = WebmViewController(url: attachment.url)
            
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
            controller.chan = chan
            controller.mode = .reply(threadNumber: info.threadNumber)
        }
    }

    func scrollToBottom() {
        if posts.count > 0 {
            let indexPath = IndexPath(row: posts.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @IBAction func titleTouched(_ sender: AnyObject) {
        tableView.setContentOffset(CGPoint.init(x: 0, y: 0 - tableView.contentInset.top), animated: true)
    }
    
    @IBAction func goDownButtonTapped(_ sender: Any) {
        if isLoading {
            needsScrollToBottom = true
        }
        scrollToBottom()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
         do {
            try uiRealm.write {
                if isInFavorites {
                    uiRealm.delete(uiRealm.objects(FavoriteThread.self).filter("board == %@ AND number == %@", info.boardId, info.threadNumber))
                    
                    isInFavorites = !isInFavorites
                } else if posts.count > 0 {
                    uiRealm.add(FavoriteThread.create(boardId: info.boardId, threadNumber: info.threadNumber, opPost: posts.first!, postsCount: posts.count, unreadPosts: unreadPosts))
                    
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
