//
//  ChatViewController+RequestMessage.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//
import UIKit

extension ChatViewController {
    func checkIsRequestMessage() -> Bool {
        return mode == .messageRequest
    }
    
    func configureRequestMessageView() {
        guard let requestMessage = viewModel.requestMessage else {
            return
        }
        
        messagesCollectionView.isHidden = true
        messageInputBar.isHidden = true
        
        requestView.isHidden = false
        
        viewModel.delegate = self
        
        myConfessionView.layer.cornerRadius = 10
        myConfessionView.backgroundColor = .backgroundCard
        myConfessionView.layer.borderColor = UIColor.textSecondary.cgColor
        myConfessionView.layer.borderWidth = 0.5
        
        messageView.layer.cornerRadius = 10
        messageView.backgroundColor = .backgroundCard
        
        profileIconView.layer.cornerRadius = profileIconView.frame.height / 2
        profileIconView.clipsToBounds = true
        
        buttonView.layer.borderWidth = 0.2
        buttonView.layer.borderColor = UIColor.textSecondary.cgColor
        
        rejectButton.backgroundColor = .statusError.withAlphaComponent(0.2)
        rejectButton.layer.cornerRadius = 8
        approveButton.backgroundColor = .brandPrimary.withAlphaComponent(0.2)
        approveButton.layer.cornerRadius = 8
        
        self.view.bringSubviewToFront(requestView)
        
        myMessageLabel.text = requestMessage.confessionMessage
        titleLabel.text = requestMessage.confessionTitle
        profileIconLabel.text = String(requestMessage.requesterUsername.prefix(2)).uppercased()
        initialLabel.text = requestMessage.initialMessage
    }
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SocialLinkTableViewCell", bundle: nil), forCellReuseIdentifier: "socialCell")
        tableView.contentInset = .zero
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.reloadData()
    }
}
extension ChatViewController {
    func didApproveRequest() {
        DispatchQueue.main.async {
            self.mode = .directMessage
            self.setupMessageKit()
            self.initData()
        }
    }
    
    func didRejectRequest() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
