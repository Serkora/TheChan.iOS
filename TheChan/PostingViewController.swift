//
//  PostingViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 15.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

enum PostingMode {
    case reply(threadNumber: Int)
    case newThread
}

class PostingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {

    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var captchaField: UITextField!
    @IBOutlet weak var opSwitch: UISwitch!
    @IBOutlet weak var sageSwitch: UISwitch!
    @IBOutlet weak var captchaView: UIView!
    @IBOutlet weak var captchaActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captchaImageView: UIImageView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    
    lazy var chan: Chan! = nil
    var boardId: String = ""
    var captcha: Captcha?
    var mode: PostingMode = .newThread
    private var attachments = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
        setupTitle()
        setupCaptcha()
        attachButton.layer.borderColor = view.tintColor.cgColor
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.reloadData()
    }
    
    func setupTitle() {
        switch mode {
        case .reply(_):
            title = NSLocalizedString("POSTING_REPLY_MODE_TITLE", comment: "Reply")
            break
        case .newThread:
            title = NSLocalizedString("POSTING_NEW_THREAD_MODE_TITLE", comment: "New thread")
            break
        }
    }
    
    func setupCaptcha() {
        captchaImageView.kf.indicatorType = .activity
        captchaImageView.isUserInteractionEnabled = true
        
        chan.isCaptchaEnabled(in: boardId) { isCaptchaEnabled in
            self.captchaActivityIndicator.stopAnimating()
            if isCaptchaEnabled {
                self.chan.getCaptcha { captcha in
                    self.captchaView.isHidden = false
                    guard let imageCaptcha = captcha as? ImageCaptcha else { return }
                    self.captcha = imageCaptcha
                    guard let url = imageCaptcha.imageURL else { return }
                    self.captchaImageView.kf.setImage(with: url)
                }
            }
        }
    }
    
    @IBAction func captchaTapped(_ sender: UITapGestureRecognizer) {
        setupCaptcha()
    }
    
    func setupFields() {
        let fields: [UITextField] = [subjectField, nameField, emailField, captchaField]
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
    
    @IBAction func emailChanged(_ sender: UITextField) {
        sageSwitch.setOn(sender.text?.lowercased() == "sage", animated: true)
    }
    
    @IBAction func sageSwitchValueChanged(_ sender: UISwitch) {
        emailField.text = sender.isOn ? "sage" : nil
    }
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        let postingData = PostingData()
        postingData.text = postTextView.text
        postingData.boardId = boardId
        postingData.subject = subjectField.text ?? ""
        postingData.email = emailField.text ?? ""
        postingData.name = nameField.text ?? ""
        postingData.isOp = opSwitch.isOn
        for attachment in attachments {
            guard let data = UIImageJPEGRepresentation(attachment, 1.0) else { continue }
            let postingAttachment = PostingAttachment()
            postingAttachment.data = data
            postingAttachment.mimeType = "image/jpeg"
            postingAttachment.name = "image.jpeg"
            postingData.attachments.append(postingAttachment)
        }
        
        if captcha != nil {
            let captchaResult = CaptchaResult()
            captchaResult.key = captcha!.key
            captchaResult.input = captchaField.text ?? ""
            postingData.captchaResult = captchaResult
        }
        
        if case .reply(let threadNumber) = mode {
            postingData.boardId = boardId
            postingData.threadNumber = threadNumber
        }
        
        chan.send(post: postingData) { isSuccessful, error, postNumber in
            if !isSuccessful {
                let error = error ?? NSLocalizedString("UNKNOWN_ERROR", comment: "Unknown error")
                let alert = UIAlertController(title: NSLocalizedString("POSTING_ERROR", comment: "Error"), message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                sender.isEnabled = true
            } else if case .reply(_) = self.mode {
                self.performSegue(withIdentifier: "UnwindToThread", sender: self)
            } else if case .newThread = self.mode {
                self.navigateToThread(by: postNumber ?? 0)
            }
        }
        
        postTextView.resignFirstResponder()
    }
    
    func navigateToThread(by number: Int) {
        guard var viewControllers = navigationController?.viewControllers else { return }
        guard let threadController = storyboard?.instantiateViewController(withIdentifier: "ThreadVC") as? ThreadTableViewController else { return }
        threadController.chan = chan
        threadController.info = (boardId: boardId, threadNumber: number)
        viewControllers.removeLast()
        viewControllers.append(threadController)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @IBAction func attachButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        attachments.append(image)
        if attachments.count >= chan.maxAttachments {
            attachButton.isEnabled = false
            attachButton.layer.borderColor = attachButton.currentTitleColor.cgColor
        }
        
        attachmentsCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - UICollectionViewDataSource for attachments
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCollectionViewCell", for: indexPath) as! AttachmentCollectionViewCell
        let image = attachments[indexPath.item]
        cell.previewImageView.image = image
        return cell
    }
}
