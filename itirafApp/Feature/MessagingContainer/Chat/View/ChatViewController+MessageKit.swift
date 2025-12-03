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
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        let labelHeight: CGFloat = 20
        let defaultSpacing: CGFloat = 0
        
        let isLastMessage = indexPath.section == viewModel.messages.count - 1
        
        if isLastMessage {
            return labelHeight
        }
        
        let nextMessage = viewModel.messages[indexPath.section + 1]
        
        if message.sender.senderId != nextMessage.sender.senderId {
            return labelHeight
        }
        
        return defaultSpacing
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .brandSecondary : .backgroundCard
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .textPrimary : .textPrimary
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
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let isLastMessage = indexPath.section == viewModel.messages.count - 1
        var showDate = isLastMessage
        
        if !isLastMessage {
            let nextMessage = viewModel.messages[indexPath.section + 1]
            if message.sender.senderId != nextMessage.sender.senderId {
                showDate = true
            }
        }
        
        if showDate {
            return NSAttributedString(
                string: message.sentDate.formattedTime(),
                attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.textTertiary]
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
        inputBar.inputTextView.placeholder = "chat.input.placeholder".localized
    }
}
