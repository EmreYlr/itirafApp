//
//  RequestBottomSheetViewController.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import UIKit

final class RequestBottomSheetViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var shareSwitch: UISwitch!
    
    var viewModel: RequestBottomSheetViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = RequestBottomSheetViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    private func initUI() {
        sendButton.layer.cornerRadius = 8
        sendButton.backgroundColor = .systemMint.withAlphaComponent(0.2)
        
        messageTextView.layer.cornerRadius = 8
        messageTextView.layer.borderWidth = 0.2
        messageTextView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func initData() {
        viewModel.delegate = self
        messageTextView.delegate = self
        
        shareSwitch.isOn = true
        
        messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func updateTextFields() {
        self.messageTextView.text.removeAll()
        self.placeholderLabel.isHidden = false
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false

        do {
            let messageText = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            guard !messageText.isEmpty else {
                throw ValidationError.emptyField(fieldName: "general.field.message".localized)
            }

            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                await viewModel.sendRequest(message: messageText, shareSocialLinks: shareSwitch.isOn)
            }
            
        } catch {
            sender.isEnabled = true
            self.handleError(error)
        }
    }
}

extension RequestBottomSheetViewController: RequestBottomSheetViewModelDelegate {
    func didSendRequestSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            self?.updateTextFields()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func didFailToSendRequest(with error: any Error) {
        DispatchQueue.main.async { [weak self] in
            self?.handleError(error)
        }
    }
}

extension RequestBottomSheetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !messageTextView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageTextView.layer.borderColor = UIColor.systemMint.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
