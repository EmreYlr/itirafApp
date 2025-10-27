//
//  ChatViewController+MessageKit.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return viewModel.currentSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 2)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 20
        }
        
        let previousMessage = viewModel.messages[indexPath.section - 1]
        if message.sender.senderId != previousMessage.sender.senderId {
            return 20
        }
        
        return 0
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemMint : .systemGray5
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .label
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if !isFromCurrentSender(message: message) {
            let avatar = Avatar(initials: String(message.sender.displayName.prefix(2).uppercased()))
            avatarView.set(avatar: avatar)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == 0 {
            return NSAttributedString(
                string: message.sentDate.formattedTime(),
                attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.systemGray]
            )
        }
        
        let previousMessage = viewModel.messages[indexPath.section - 1]
        if message.sender.senderId != previousMessage.sender.senderId {
            return NSAttributedString(
                string: message.sentDate.formattedTime(),
                attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.systemGray]
            )
        }
        
        return nil
    }

}


// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else { return }
        
        viewModel.sendMessage(trimmedText)
        
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = "Mesaj yazın..."
    }
}
