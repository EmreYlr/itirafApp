//
//  ChatViewController.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
    //MARK: - Properties
    var viewModel: ChatViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ChatViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageKit()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // Mesaj baloncuğu görünümü
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = CGSize(width: 30, height: 30)
        }
        
        // Scroll to bottom butonu
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        showMessageTimestampOnSwipeLeft = true
    }
    
    private func initData() {
        viewModel.delegate = self
        
        // Başlık olarak karşı tarafın adını göster
        if let directMessage = viewModel.directMessage {
            navigationItem.title = directMessage.senderUsername
        } else {
            navigationItem.title = "Chat"
        }
        
        // Mock mesajları yükle
        viewModel.loadMockMessages()
    }

}

// MARK: - ChatViewModelDelegate
extension ChatViewController: ChatViewModelDelegate {
    func didUpdateMessages() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func diderror(_ error: any Error) {
        print("Error occurred: \(error.localizedDescription)")
    }
}

