//
//  PersonViewController.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

final class PersonViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var addNewSocialButton: UIButton!
    
    var personViewModel: PersonViewModelProtocol
    required init?(coder: NSCoder) {
        self.personViewModel = PersonViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PersonViewController")
        initData()
        loadCollectionView()
    }
    
    
    func initData() {
        personViewModel.delegate = self
        logoutButton.layer.cornerRadius = 8
        addNewSocialButton.layer.cornerRadius = 8
        
        usernameLabel.text = UserManager.shared.getUsername()
        personView.layer.cornerRadius = personView.frame.width / 2
        personView.clipsToBounds = true
        personView.layer.borderWidth = 1
        personView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        personImageView.image = UIImage(named: "avatar_icon")
        privacyView.layer.cornerRadius = 8
        privacyView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        
        let more = UIImage(systemName: "line.3.horizontal")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: more , style: .done, target: self, action: #selector(moreButtonTapped))

        Task {
            await personViewModel.getUserSocialLinks()
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SocialCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "socialCell")
    }

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let performLogoutAction = {
            sender.isEnabled = false
            Task {
                defer {
                    sender.isEnabled = true
                }
                await self.personViewModel.logout()
            }
        }
        
        if personViewModel.checkUserAnonymous() {
            performLogoutAction()
        } else {
            showTwoButtonAlert(
                title: "Çıkış Yap",
                message: "Çıkış yapmak istediğinizden emin misiniz?",
                firstButtonTitle: "Çıkış Yap",
                firstButtonHandler: { _ in
                    performLogoutAction()
                },
                secondButtonTitle: "İptal",
                secondButtonHandler: nil
            )
        }
    }
    
    @IBAction func addNewSocialButtonTapped(_ sender: UIButton) {
        let editSocialVC: EditSocialViewController = Storyboard.editSocial.instantiate(.editSocial)
        editSocialVC.source = .addButton
        editSocialVC.viewModel = EditSocialViewModel(socialLinks: personViewModel.socialLinks?.links ?? [])
        editSocialVC.onSave = { [weak self] in
            Task {
                await self?.personViewModel.getUserSocialLinks()
            }
        }
        navigationController?.pushViewController(editSocialVC, animated: true)
    }
    
    @objc private func moreButtonTapped() {
        
    }
}

extension PersonViewController: PersonViewModelOutputProtocol {
    func didUpdateSocialLinks() {
        collectionView.reloadData()
    }
    
    func didFailSocialLinks(with error: any Error) {
        print(error)
    }
    
    func didLogoutSuccessfully() {
        print("Logout Başarılı")
        let loginNavigationController = Storyboard.login.instantiateNav(.loginNav)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = loginNavigationController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func didFailToLogout(with error: any Error) {
        print(error)
    }
}
