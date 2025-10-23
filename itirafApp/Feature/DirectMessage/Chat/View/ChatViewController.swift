//
//  ChatViewController.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import UIKit

final class ChatViewController: UIViewController {
    //MARK: - Properties
    var viewModel: ChatViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ChatViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatViewController")
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "Chat"
    }

}

extension ChatViewController: ChatViewModelDelegate {
    func didUpdateChat() {
        print("Chat updated")
    }
    
    func diderror(_ error: any Error) {
        print("Error occurred: \(error.localizedDescription)")
    }
    
    
}
