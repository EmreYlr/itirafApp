//
//  ChatViewController.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import UIKit
import MessageKit
import InputBarAccessoryView

enum ChatScreenMode {
    case directMessage
    case messageRequest
}

final class ChatViewController: MessagesViewController {
    //MARK: - Properties
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myConfessionView: UIView!
    @IBOutlet weak var profileIconView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var myMessageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileIconLabel: UILabel!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    
    var viewModel: ChatViewModelProtocol
    private var isFirstLoad = true
    var mode: ChatScreenMode = .directMessage
    
    required init?(coder: NSCoder) {
        self.viewModel = ChatViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLoadView()
        setupTheme()
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
    
    private func initLoadView() {
        if checkIsRequestMessage() {
            configureRequestMessageView()
            configureTableView()
        } else {
            setupMessageKit()
            initData()
        }
    }
    
    private func setupTheme() {
        view.backgroundColor = .backgroundApp
        messagesCollectionView.backgroundColor = .backgroundApp
        messageInputBar.backgroundColor = .backgroundApp
        messageInputBar.backgroundView.backgroundColor = .backgroundApp
        requestView.backgroundColor = .backgroundApp
        tableView.backgroundColor = .backgroundApp
    }
     
    func setupMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .brandPrimary
        config.baseForegroundColor = .textPrimary
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        config.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0)
        messageInputBar.sendButton.configuration = config
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.padding.right = 8
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
            layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
            layout.setMessageOutgoingAvatarSize(.zero)
        }
        
        scrollsToLastItemOnKeyboardBeginsEditing = false
        maintainPositionOnInputBarHeightChanged = true
        showMessageTimestampOnSwipeLeft = true
    }
    
    func initData() {
        requestView.isHidden = true
        messagesCollectionView.isHidden = false
        messageInputBar.isHidden = false
        self.view.bringSubviewToFront(messagesCollectionView)
        self.view.bringSubviewToFront(inputContainerView)
        
        viewModel.delegate = self
        
        if let directMessage = viewModel.directMessage {
            navigationItem.title = directMessage.username
            Task {
                await viewModel.fetchRoomMessages()
                viewModel.startListening()
            }
        } else {
            navigationItem.title = "chat.title.default".localized
        }
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        Task(priority: .utility) {
            await viewModel.rejectRequest()
        }
    }
    
    
    @IBAction func approveButtonTapped(_ sender: UIButton) {
        Task(priority: .utility) {
            await viewModel.approveRequest()
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
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}
