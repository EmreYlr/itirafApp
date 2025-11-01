//
//  ChatViewController+ScrollView.swift
//  itirafApp
//
//  Created by Emre on 27.10.2025.
//

import UIKit

extension ChatViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView.contentOffset.y < 100.0 {
            guard !viewModel.isLoading, viewModel.hasMoreData else {
                return
            }
            if scrollView.contentOffset.y < 100.0, !checkIsRequestMessage() {
                Task {
                    await viewModel.fetchRoomMessages()
                }
            }
            
        }
    }
}
