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
    var onSave: (() -> Void)?
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sil" , style: .done, target: self, action: #selector(deleteButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        
        if source == .editButton, let link = viewModel.getUserSocialLinks() {
            navigationItem.title = "Hesap Düzenle"
            navigationItem.rightBarButtonItem?.isHidden = false
            platformSelectButton.setTitle(link.platform.displayName, for: .normal)
            platformUsernameTextField.text = link.username
            platformUserLinkTextField.text = link.url
            selectedPlatform = link.platform
            addOrEditButton.setTitle("Hesabı Düzenle", for: .normal)
        } else {
            navigationItem.title = "Hesap Ekle"
            navigationItem.rightBarButtonItem?.isHidden = true
            addOrEditButton.setTitle("Hesap Ekle", for: .normal)
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
            showOneButtonAlert(title: "Hata", message: "Lütfen kullanıcı adını girin.", buttonTitle: "Tamam")
            return false
        }
        
        if let platformUsername = viewModel.socialLink?.username,  platformUsername == platformUsernameTextField.text {
            showOneButtonAlert(title: "Hata", message: "Lütfen farklı bir kullanıcı adı girin.", buttonTitle: "Tamam")
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
            showOneButtonAlert(title: "Hata", message: "Lütfen bir platform seçin.", buttonTitle: "Tamam")
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
        showTwoButtonAlert(title: "Uyarı", message: "Sosyal medya hesabınızı silmek istediğinizden emin misiniz?", firstButtonTitle: "Evet", firstButtonHandler: { _ in
            Task(priority: .utility) {
                await self.viewModel.deleteSocialLink()
            }
        }, secondButtonTitle: "İptal", secondButtonHandler: nil)
    }
        
}

extension EditSocialViewController: EditSocialViewModelDelegate {
    func didCreateSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "Başarılı", message: "Sosyal medya hesap bilgileriniz başarılı bir şekilde eklendi.", buttonTitle: "Tamam") { [weak self] _ in
                self?.onSave?()
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func didUpdateSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "Başarılı", message: "Sosyal medya hesap bilgileriniz başarılı bir şekilde güncellendi.", buttonTitle: "Tamam") { [weak self] _ in
                self?.onSave?()
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func didDeleteSocialLinks() {
        DispatchQueue.main.async { [weak self] in
            self?.onSave?()
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func didFailSocialLinks(with error: any Error) {
        print("Error updating social links: \(error.localizedDescription)")
    }
}
