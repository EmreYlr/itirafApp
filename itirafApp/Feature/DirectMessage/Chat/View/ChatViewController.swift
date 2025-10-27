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
    private var isFirstLoad = true
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            viewModel.stopListening()
        }
    }
     
    private func setupMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
            layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
            layout.setMessageOutgoingAvatarSize(.zero)
        }
        
        scrollsToLastItemOnKeyboardBeginsEditing = false
        maintainPositionOnInputBarHeightChanged = true
        showMessageTimestampOnSwipeLeft = true
    }
    
    private func initData() {
        viewModel.delegate = self
        
        if let directMessage = viewModel.directMessage {
            navigationItem.title = directMessage.username
            Task {
                await viewModel.fetchRoomMessages()
                viewModel.startListening()
            }
        } else {
            navigationItem.title = "Chat"
        }
        
    }
    
}

// MARK: - ChatViewModelDelegate
extension ChatViewController: ChatViewModelDelegate {
    func didUpdateMessages(isPagination: Bool) {
        DispatchQueue.main.async {
            if isPagination {
                self.messagesCollectionView.reloadDataAndKeepOffset()
                
            } else {
                self.messagesCollectionView.reloadData()
                
                if self.isFirstLoad {
                    self.messagesCollectionView.layoutIfNeeded()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                    self.isFirstLoad = false
                    
                } else {
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
        }
    }
    
    
    func diderror(_ error: Error) {
        print("❌ Sohbet Hatası Oluştu: \(error.localizedDescription)")
    }
}
