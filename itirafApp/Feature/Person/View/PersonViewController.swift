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
        addNewSocialButton.layer.cornerRadius = 8
        
        usernameLabel.text = UserManager.shared.getUsername() ?? "Anonymous"
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
        let settingsVC = Storyboard.settings.instantiate(.settings)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

extension PersonViewController: PersonViewModelOutputProtocol {
    func didUpdateSocialLinks() {
        collectionView.reloadData()
    }
    
    func didFailSocialLinks(with error: any Error) {
        print(error)
    }
}
