//
//  EditSocialViewController.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import UIKit

enum EditSource {
    case editButton
    case addButton
}

final class EditSocialViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var platformSelectButton: UIButton!
    @IBOutlet weak var platformUsernameTextField: UITextField!
    @IBOutlet weak var platformUserLinkTextField: UITextField!
    @IBOutlet weak var addOrEditButton: UIButton!
    
    private var selectedPlatform: SocialPlatform?
    var source: EditSource?
    var viewModel: EditSocialViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = EditSocialViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EditSocial")
        initData()
        initUI()
        setupMenu()
        setupTextFieldListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initUI() {
        addOrEditButton.layer.cornerRadius = 8
        platformSelectButton.layer.cornerRadius = 8
        platformSelectButton.layer.borderWidth = 0.5
        platformSelectButton.layer.borderColor = UIColor.systemGray4.cgColor

    }
    private func initData() {
        viewModel.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "general.button.delete".localized , style: .done, target: self, action: #selector(deleteButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        
        if source == .editButton, let link = viewModel.getUserSocialLinks() {
            navigationItem.title = "social.title.edit_account".localized
            navigationItem.rightBarButtonItem?.isHidden = false
            platformSelectButton.setTitle(link.platform.displayName, for: .normal)
            platformUsernameTextField.text = link.username
            platformUserLinkTextField.text = link.url
            selectedPlatform = link.platform
            addOrEditButton.setTitle("social.button.edit_account".localized, for: .normal)
        } else {
            navigationItem.title = "social.title.add_account".localized
            navigationItem.rightBarButtonItem?.isHidden = true
            addOrEditButton.setTitle("social.title.add_account".localized, for: .normal)
        }
        
    }
    
    private func setupMenu() {
        let actions = viewModel.getAllSocialPlatforms().map { platform in
            let isAlreadyAdded = viewModel.socialLinks?.contains(where: { $0.platform.rawValue == platform.rawValue }) ?? false
            
            return UIAction(
                title: platform.displayName,
                image: UIImage(named: platform.iconName),
                attributes: isAlreadyAdded ? [.disabled] : []
            ) { [weak self] _ in
                self?.didSelectPlatform(platform)
            }
        }
        
        platformSelectButton.menu = UIMenu(children: actions)
        platformSelectButton.showsMenuAsPrimaryAction = true
    }


    private func didSelectPlatform(_ platform: SocialPlatform) {
        selectedPlatform = platform
        platformSelectButton.setTitle(platform.displayName, for: .normal)
        updateUserLinkField()
    }
    
    private func updateUserLinkField() {
        guard let platform = selectedPlatform else {
            platformUserLinkTextField.text = ""
            return
        }
        let username = platformUsernameTextField.text ?? ""
        platformUserLinkTextField.text = "\(platform.baseURL)\(username)"
    }
    
    private func setupTextFieldListener() {
        platformUsernameTextField.addTarget(self, action: #selector(usernameDidChange), for: .editingChanged)
    }
    
    private func validateInput() -> Bool {
        guard let username = platformUsernameTextField.text, !username.isEmpty else {
            showOneButtonAlert(title: "error.unknown".localized, message: "social.error.message.enter_username".localized, buttonTitle: "general.button.ok".localized)
            return false
        }
        
        if let platformUsername = viewModel.socialLink?.username,  platformUsername == platformUsernameTextField.text {
            showOneButtonAlert(title: "error.unknown".localized, message: "social.error.message.enter_different_username".localized, buttonTitle: "general.button.ok".localized)
            return false
        }
        
        return true
    }
    
    @objc private func usernameDidChange() {
        updateUserLinkField()
    }

    @IBAction func addOrEditButtonTapped(_ sender: UIButton) {
        guard let newUsername = platformUsernameTextField.text else {
            return
        }
        
        guard let selectedPlatform = selectedPlatform else {
            showOneButtonAlert(title: "error.unknown".localized, message: "social.error.message.select_platform".localized, buttonTitle: "general.button.ok".localized)
            return
        }
        
        if source.self == .addButton {
            Task(priority: .utility) {
                await viewModel.createSocialLink(username: newUsername, platform: selectedPlatform)
            }
        } else {
            if !validateInput() {
                return
            }
            Task(priority: .utility) {
                await viewModel.editSocialLink(newUsername: newUsername)
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
        showTwoButtonAlert(title: "general.title.warning".localized, message: "social.message.delete_confirmation".localized, firstButtonTitle: "general.button.yes".localized, firstButtonHandler: { _ in
            Task(priority: .utility) {
                await self.viewModel.deleteSocialLink()
            }
        }, secondButtonTitle: "general.button.cancel".localized, secondButtonHandler: nil)
    }
        
}

extension EditSocialViewController: EditSocialViewModelDelegate {
    func didCreateSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "success.title".localized, message: "social.success.message.added".localized, buttonTitle: "general.button.ok".localized) { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func didUpdateSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "success.title".localized, message: "social.success.message.updated".localized, buttonTitle: "general.button.ok".localized) { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func didDeleteSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func didFailSocialLinks(with error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}
