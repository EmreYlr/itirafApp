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
        myConfessionView.backgroundColor = .systemGray6
        myConfessionView.layer.borderColor = UIColor.systemGray4.cgColor
        myConfessionView.layer.borderWidth = 0.5
        
        messageView.layer.cornerRadius = 10
        messageView.backgroundColor = .systemGray6
        
        profileIconView.layer.cornerRadius = profileIconView.frame.height / 2
        profileIconView.clipsToBounds = true
        
        buttonView.layer.borderWidth = 0.2
        buttonView.layer.borderColor = UIColor.systemGray4.cgColor
        
        rejectButton.backgroundColor = .systemRed.withAlphaComponent(0.2)
        rejectButton.layer.cornerRadius = 8
        approveButton.backgroundColor = .systemMint.withAlphaComponent(0.2)
        approveButton.layer.cornerRadius = 8
        
        //TODO: - Mesaj kısmı doldurulacak
        myMessageLabel.text = "Bu kısıma itirafın mesajı gelecek. O yüzden bu mesajı biraz uzun yazıyorum. Şuan için test ediyorum."
//        titleLabel.text = requestMessage.confessionTitle
        titleLabel.text = "Bu bir itiraftır."
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
