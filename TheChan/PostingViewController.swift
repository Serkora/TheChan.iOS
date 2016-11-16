//
//  PostingViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 15.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit

enum PostingMode {
    case reply(boardId: String, threadNumber: Int)
    case newThread(boardId: String)
}

class PostingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var mode: PostingMode = .newThread(boardId: "board")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fields: [UITextField] = [subjectField, nameField, emailField]
        for field in fields {
            field.layer.borderWidth = 1.0
            field.layer.borderColor = UIColor.darkGray.cgColor
            field.layer.cornerRadius = 5.0
            field.attributedPlaceholder = NSAttributedString(string: field.placeholder ?? "", attributes: [
                NSForegroundColorAttributeName: UIColor.lightText
            ])
            field.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        let postingData = PostingData()
        postingData.text = postTextView.text
        if case .reply(let boardId, let threadNumber) = mode {
            postingData.boardId = boardId
            postingData.threadNumber = threadNumber
        } else if case .newThread(let boardId) = mode {
            postingData.boardId = boardId
        }
        
        postTextView.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
