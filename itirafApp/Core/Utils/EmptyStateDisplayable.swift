//
//  EmptyStateDisplayable.swift
//  itirafApp
//
//  Created by Emre on 8.12.2025.
//

import UIKit

enum EmptyStateType {
    case noMessages
    case noRequestMessages
    case noSentRequestMessages
    case noNotifications
    case noFollowingChannels
    case noSocialMediaLinks
    case noMyConfessions
    case error(String)
    
    var systemImageName: String {
        switch self {
        case .noMessages: return "bubble.left.and.bubble.right"
        case .noRequestMessages: return "envelope.badge"
        case .noSentRequestMessages: return "paperplane"
        case .noNotifications: return "bell.slash"
        case .noFollowingChannels: return "person.2.slash"
        case .noSocialMediaLinks: return "link"
        case .noMyConfessions: return "quote.bubble"
        case .error: return "exclamationmark.triangle"
        }
    }

    var title: String {
        switch self {
        case .noMessages: return "empty.noMessages.title".localized
        case .noRequestMessages: return "empty.noRequestMessages.title".localized
        case .noSentRequestMessages: return "empty.noSentRequestMessages.title".localized
        case .noNotifications: return "empty.noNotifications.title".localized
        case .noFollowingChannels: return "empty.noFollowingChannels.title".localized
        case .noSocialMediaLinks: return "empty.noSocialMediaLinks.title".localized
        case .noMyConfessions: return "empty.noMyConfessions.title".localized
        case .error(let message): return message
        }
    }
    
    var buttonTitle: String? {
        switch self {
        case .noFollowingChannels: return "empty.noFollowingChannels.button".localized
        case .noMyConfessions: return "empty.noMyConfessions.button".localized
        case .error: return "empty.error.button".localized
        default: return nil
        }
    }
}

protocol EmptyStateDisplayable {
    func showEmptyState(type: EmptyStateType, in collectionView: UICollectionView, action: (() -> Void)?)
    func hideEmptyState(from collectionView: UICollectionView)
}

extension EmptyStateDisplayable where Self: UIViewController {
    
    func showEmptyState(type: EmptyStateType, in collectionView: UICollectionView, action: (() -> Void)? = nil) {
        
        hideEmptyState(from: collectionView)
        let emptyView = EmptyStateView()
        emptyView.configure(with: type, action: action)
        collectionView.backgroundView = emptyView
    }
    
    func hideEmptyState(from collectionView: UICollectionView) {
        collectionView.backgroundView = nil
    }
}
