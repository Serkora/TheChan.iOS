//
//  PostingViewController.swift
//  TheChan
//
//  Created by Вадим Новосельцев on 15.11.16.
//  Copyright © 2016 ACEDENED Software. All rights reserved.
//

import UIKit
import Kingfisher

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
    @IBOutlet weak var captchaView: UIView!
    @IBOutlet weak var captchaActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captchaImageView: UIImageView!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    
    var boardId: String = ""
    var captcha: Captcha?
    var mode: PostingMode = .newThread
    private var attachments = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
        setupCaptcha()
        attachButton.layer.borderColor = view.tintColor.cgColor
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.reloadData()
    }
    
    func setupCaptcha() {
        captchaImageView.kf.indicatorType = .activity
        
        Facade.isCaptchaEnabled(in: boardId) { isCaptchaEnabled in
            self.captchaActivityIndicator.stopAnimating()
            if isCaptchaEnabled {
                Facade.getCaptcha { captcha in
                    self.captchaView.isHidden = false
                    guard let imageCaptcha = captcha as? ImageCaptcha else { return }
                    self.captcha = imageCaptcha
                    guard let url = imageCaptcha.imageURL else { return }
                    self.captchaImageView.kf.setImage(with: url)
                }
            }
        }
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
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        let postingData = PostingData()
        postingData.text = postTextView.text
        postingData.boardId = boardId
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
        
        Facade.send(post: postingData) { isSuccessful, error in
            if !isSuccessful {
                let error = error ?? NSLocalizedString("UNKNOWN_ERROR", comment: "Unknown error")
                let alert = UIAlertController(title: NSLocalizedString("POSTING_ERROR", comment: "Error"), message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                sender.isEnabled = true
            } else {
                self.performSegue(withIdentifier: "UnwindToThread", sender: self)
            }
        }
        
        postTextView.resignFirstResponder()
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
