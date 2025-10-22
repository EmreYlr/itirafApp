//
//  PostConfessionViewController.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//

import UIKit

final class PostConfessionViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var postConfessionViewModel: PostConfessionViewModelProtocol
    
    required init?(coder: NSCoder) {
        postConfessionViewModel = PostConfessionViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    private func initUI() {
        postConfessionViewModel.delegate = self
        
        contentTextView.delegate = self
        titleTextField.delegate = self
        
        contentTextView.layer.borderColor = UIColor.systemGray.cgColor
        contentTextView.layer.borderWidth = 2
        contentTextView.layer.cornerRadius = 6
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.borderColor = UIColor.systemGray.cgColor
        shareButton.layer.cornerRadius = 8
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contentText = contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if titleText.isEmpty || contentText.isEmpty {
            showOneButtonAlert(title: "Uyarı", message: "Lütfen başlık ve açıklamayı doldurun.", buttonTitle: "Tamam")
            return
        }
        
        let content = PostConfession(title: titleText, message: contentText)
        
//        sender.isEnabled = false
//        activityIndicator.startAnimating()
        
        Task {
//            defer {
//                // Animasyonu durdur ve butonu tekrar aktif et
//                activityIndicator.stopAnimating()
//                sender.isEnabled = true
//            }
            await postConfessionViewModel.postConfession(content: content)
        }
        
    }
    
    private func updateTextFields() {
        self.titleTextField.text = ""
        self.contentTextView.text.removeAll()
        self.placeholderLabel.isHidden = false
    }
    
}

extension PostConfessionViewController: PostConfessionViewModelOutputProtocol {
    func didPostConfessionSuccessfully() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: "Başarılı", message: "İtirafınız başarıyla paylaşıldı.", buttonTitle: "Tamam") { _ in
                self.updateTextFields()
                self.navigationController?.popToRootViewController(animated: false)
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func didFailToPostConfession(with error: Error) {
        print(error)
    }
}


extension PostConfessionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentTextView.layer.borderColor = UIColor.systemMint.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension PostConfessionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextField.layer.borderColor = UIColor.systemMint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
