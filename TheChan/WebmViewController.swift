//
//  WebmView.swift
//  TheChan
//
//  Created by Sergey Korabanov on 20/11/16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import Foundation
import UIKit
import OGVKit

class WebmViewController: UIViewController, OGVPlayerDelegate {
  
    override var prefersStatusBarHidden : Bool {
        return true
    }
    private var videoUrl: URL!
    private var player: OGVPlayerView!
    private var autoplay: Bool!
    private var loop: Bool! = false
    
    convenience init(url: URL, _ autoplay: Bool = true) {
        self.init(nibName: nil, bundle: nil)
        self.videoUrl = url
        self.autoplay = autoplay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
        
        player = OGVPlayerView.init(frame: self.view.bounds)
        player.delegate = self
        self.view.addSubview(player)
        
        player.sourceURL = videoUrl

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.autoplay!){
            player.play()
            self.hideControls()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil, completion: {_ in
            let rect = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: size)
            self.player.frameView.frame = rect
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }

    func setVideo(_ url: URL, _ autoplay: Bool = false){
        videoUrl = url
        self.autoplay = autoplay
    }
    
    func hideControls(){
        // copy-paste of a method stupidly made private
        UIView.animate(withDuration: 0.5, animations: {
            self.player.controlBar.alpha = 0
        })
    }
    
    func showControls(){
        // copy-paste of a method stupidly made private
        UIView.animate(withDuration: 0.5, animations: {
            self.player.controlBar.alpha = 1
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    func ogvPlayerDidPlay(_ sender: OGVPlayerView!) {
        if (self.autoplay!){
            self.hideControls()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.autoplay = false               // So that controls are auto-hidden only the first time video plays
        }
    }
    
    func ogvPlayerDidEnd(_ sender: OGVPlayerView!) {
        // workaround to replay the video without closing the view/controller
        self.autoplay = self.loop
        player.sourceURL = videoUrl
    }
    
    func ogvPlayerControlsWillShow(_ sender: OGVPlayerView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func ogvPlayerControlsWillHide(_ sender: OGVPlayerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func ogvPlayerDidLoadMetadata(_ sender: OGVPlayerView!) {
    }
}
