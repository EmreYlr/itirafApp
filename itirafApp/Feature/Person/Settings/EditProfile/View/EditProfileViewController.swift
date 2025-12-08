//
//  EditProfileViewController.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

import UIKit

final class EditProfileViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var usernameTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func initUI() {
        usernameTitleLabel.text = "person.username_title".localized
        emailTitleLabel.text = "person.email_title".localized
        deleteButton.setTitle("person.delete_account_button_title".localized, for: .normal)
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 6
        emailTextField.layer.borderColor = UIColor.divider.cgColor
        emailTextField.clipsToBounds = true
        
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 6
        usernameTextField.layer.borderColor = UIColor.divider.cgColor
        emailTextField.clipsToBounds = true
        
        deleteButton.layer.cornerRadius = 8
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "person.settings.edit_profile.title".localized

        guard let user = viewModel.getUserInfo() else {
            return
        }
        
        emailTextField.text = user.email
        usernameTextField.text = user.username
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        showTwoButtonAlert(title: "profile.delete_account_confirmation_title".localized, message: "profile.delete_account_confirmation_message".localized, firstButtonTitle: "profile.delete_account_yes".localized, firstButtonHandler: { _ in
            self.showLoading()
            Task(priority: .utility) {
                defer {
                    self.hideLoading()
                }
                await self.viewModel.deleteAccount()
            }
        }, secondButtonTitle: "general.button.cancel".localized)
    }
}

extension EditProfileViewController: EditProfileViewModelDelegate {
    func didDeleteProfile() {
        navigateToLogin()
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
    
    private func navigateToLogin() {
        DispatchQueue.main.async {
            let loginNavigationController = Storyboard.login.instantiateNav(.loginNav)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginNavigationController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
