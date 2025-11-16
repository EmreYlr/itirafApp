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
    @IBOutlet weak var channelSelectButton: UIButton!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if postConfessionViewModel.isChannelEmpty() {
            shareButton.isEnabled = false
        } else{
            shareButton.isEnabled = true
        }
    }
    
    private func initUI() {
        postConfessionViewModel.delegate = self
        
        contentTextView.delegate = self
        titleTextField.delegate = self
        
        contentTextView.layer.borderColor = UIColor.systemGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 6
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.borderColor = UIColor.systemGray.cgColor
        shareButton.layer.cornerRadius = 8
        
        channelSelectButton.layer.cornerRadius = 8
        channelSelectButton.layer.borderWidth = 0.5
        channelSelectButton.layer.borderColor = UIColor.systemGray4.cgColor
        
        if postConfessionViewModel.selectedChannel != nil {
            channelSelectButton.setTitle(postConfessionViewModel.selectedChannel?.title.capitalized, for: .normal)
            channelSelectButton.isEnabled = false
        }
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contentText = contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if titleText.isEmpty || contentText.isEmpty {
            showOneButtonAlert(title: "Uyarı", message: "Lütfen başlık ve açıklamayı doldurun.", buttonTitle: "Tamam")
            return
        }
        
        guard let selectedChannel = postConfessionViewModel.selectedChannel else {
            showOneButtonAlert(title: "Uyarı", message: "Lütfen bir kanal seçin.", buttonTitle: "Tamam")
            return
        }
        
        let content = PostConfession(channelId: selectedChannel.id, title: titleText, message: contentText)
        
        sender.isEnabled = false
        
        Task(priority: .utility) {
            defer {
                sender.isEnabled = true
            }
            await postConfessionViewModel.postConfession(content: content)
        }
        
    }
    
    private func updateTextFields() {
        self.titleTextField.text = ""
        self.contentTextView.text.removeAll()
        self.placeholderLabel.isHidden = false
        channelSelectButton.setTitle("Kanal Seçin", for: .normal)
    }
    
    @IBAction func channelSelectButtonTapped(_ sender: UIButton) {
        let followedChannels = FollowManager.shared.getCachedFollowedChannels()
        
        if followedChannels.isEmpty {
            showOneButtonAlert(title: "Uyarı", message: "Henüz hiçbir kanalı takip etmiyorsunuz.", buttonTitle: "Tamam")
            return
        }

        let selectionVC = ChannelSelectionViewController()
        selectionVC.channels = followedChannels
        selectionVC.delegate = self
        
        let navController = UINavigationController(rootViewController: selectionVC)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
}
    

extension PostConfessionViewController: PostConfessionViewModelOutputProtocol {
    func didPostConfessionSuccessfully() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: "Başarılı", message: "İtirafınız başarıyla paylaşıldı.", buttonTitle: "Tamam") { _ in
                self.updateTextFields()
                self.navigationController?.popToRootViewController(animated: false)
                if self.tabBarController != nil {
                    self.navigationController?.popToRootViewController(animated: false)
                    self.tabBarController?.selectedIndex = 0
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
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

extension PostConfessionViewController: ChannelSelectionDelegate {
    func didSelectChannel(_ channel: ChannelData) {
        postConfessionViewModel.selectedChannel = channel
        channelSelectButton.setTitle(channel.title.capitalized, for: .normal)
    }
}
