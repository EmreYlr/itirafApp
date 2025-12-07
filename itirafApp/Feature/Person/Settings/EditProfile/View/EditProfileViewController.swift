//
//  EditProfileViewController.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

import UIKit

final class EditProfileViewController: UIViewController {
    //MARK: - Properties
    
    var viewModel: EditProfileViewModelProtocol
    
    required init(coder: NSCoder) {
        self.viewModel = EditProfileViewModel()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    private func initUI() {
        
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "person.settings.edit_profile.title".localized
    }
}

extension EditProfileViewController: EditProfileViewModelDelegate {
    func didUpdateProfile() {
        
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
    
    
}
