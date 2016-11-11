//
//  ThreadStateViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 06.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

class ThreadStateViewController: UIViewController {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var primaryStateLabel: UILabel!
    @IBOutlet private weak var secondaryStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    var primaryState: String {
        get {
            return primaryStateLabel.text ?? ""
        }
        
        set {
            primaryStateLabel.text = newValue
        }
    }
    
    var secondaryState: String {
        get {
            return secondaryStateLabel.text ?? ""
        }
        
        set {
            secondaryStateLabel.text = newValue
        }
    }
    
    func startLoading(with text: String) {
        setIndicator(hidden: false)
        activityIndicator.startAnimating()
        
        primaryState = text
    }
    
    func endLoading(with text: String) {
        setIndicator(hidden: true)
        activityIndicator.stopAnimating()
        
        primaryState = text
    }
    
    func setIndicator(hidden: Bool) {
        UIView.transition(with: activityIndicator, duration: 0.1, options: .transitionCrossDissolve, animations: { () -> Void in
            self.activityIndicator.isHidden = hidden
        }, completion: { _ in })
    }
}
