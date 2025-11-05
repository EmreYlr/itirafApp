//
//  ModerationDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationDetailViewController: UIViewController {
    //MARK: -Properties
    var viewModel: ModerationDetailViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ModerationDetailViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    private func initData() {
        viewModel.delegate = self
    }
}

extension ModerationDetailViewController: ModerationDetailViewModelDelegate {
    func didPostDecisionSuccessfully() {
        
    }
    
    func didFailPostingDecision(_ error: any Error) {
        print("Error posting decision: \(error)")
    }
    
    
}
