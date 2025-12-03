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
    @IBOutlet weak var contentCountLabel: UILabel!
    @IBOutlet weak var titleCountLabel: UILabel!
    
    var postConfessionViewModel: PostConfessionViewModelProtocol
    
    required init?(coder: NSCoder) {
        postConfessionViewModel = PostConfessionViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupHideKeyboardOnTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
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
        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
        
        updateTitleCharacterCountLabel()
        updateCharacterCountLabel()
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        do {
            let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let contentText = contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !contentText.isEmpty else {
                throw ValidationError.emptyField(fieldName: "confession.field.content".localized)
            }
            
            guard let selectedChannel = postConfessionViewModel.selectedChannel else {
                throw ValidationError.emptyField(fieldName: "confession.field.channel".localized)
            }
            
            let content = PostConfession(channelId: selectedChannel.id, title: titleText, message: contentText)
            
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                await postConfessionViewModel.postConfession(content: content)
            }
            
        } catch {
            sender.isEnabled = true
            self.handleError(error)
        }
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateTextFields() {
        self.titleTextField.text = ""
        self.contentTextView.text.removeAll()
        self.placeholderLabel.isHidden = false
        channelSelectButton.setTitle("post_confession.button.select_channel".localized, for: .normal)
    }
    
    @IBAction func channelSelectButtonTapped(_ sender: UIButton) {
        let followedChannels = FollowManager.shared.getCachedFollowedChannels()
        
        if followedChannels.isEmpty {
            showOneButtonAlert(title: "general.title.warning".localized, message: "post_confession.alert.no_channels.message".localized, buttonTitle: "general.button.ok".localized)
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
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        updateTitleCharacterCountLabel()
    }
    
    private func updateTitleCharacterCountLabel() {
        let maxCharacterCount = postConfessionViewModel.getTitleCharrecterCount()
        
        let currentCount = titleTextField.text?.count ?? 0
        let remaining = maxCharacterCount - currentCount
        
        titleCountLabel.text = "post.title_remaining".localized(remaining)
        
        if remaining == 0 {
            titleCountLabel.textColor = .systemRed
            titleTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            titleCountLabel.textColor = .systemGray
            if titleTextField.isFirstResponder {
                titleTextField.layer.borderColor = UIColor.systemMint.cgColor
            } else {
                titleTextField.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
    
    private func updateCharacterCountLabel() {
        let maxCharacterCount = postConfessionViewModel.getContentCharrecterCount()
        
        let currentCount = contentTextView.text.count
        let remaining = maxCharacterCount - currentCount
        
        contentCountLabel.text = "post.content_remaining".localized(remaining)

        if remaining == 0 {
            contentCountLabel.textColor = .systemRed
            contentTextView.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            contentCountLabel.textColor = .systemGray
            if contentTextView.isFirstResponder {
                contentTextView.layer.borderColor = UIColor.systemMint.cgColor
            } else {
                contentTextView.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
}
    

extension PostConfessionViewController: PostConfessionViewModelOutputProtocol {
    func didPostConfessionSuccessfully() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: "general.title.success".localized, message: "post_confession.success.message".localized, buttonTitle: "general.button.ok".localized) { _ in
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
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}

extension PostConfessionViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return updatedText.count <= postConfessionViewModel.getContentCharrecterCount()
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
        
        updateCharacterCountLabel()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateCharacterCountLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateCharacterCountLabel()
    }
}

extension PostConfessionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == titleTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= postConfessionViewModel.getTitleCharrecterCount()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTitleCharacterCountLabel()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTitleCharacterCountLabel()
    }
}

extension PostConfessionViewController: ChannelSelectionDelegate {
    func didSelectChannel(_ channel: ChannelData) {
        postConfessionViewModel.selectedChannel = channel
        channelSelectButton.setTitle(channel.title.capitalized, for: .normal)
    }
}
