//
//  PersonViewController.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit
import SkeletonView

final class PersonViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var addNewSocialButton: UIButton!
    @IBOutlet weak var followedButton: UIButton!
    
    var personViewModel: PersonViewModelProtocol
    required init?(coder: NSCoder) {
        self.personViewModel = PersonViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        loadCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await personViewModel.getUserSocialLinks()
        }
    }

    func initData() {
        personViewModel.delegate = self
        addNewSocialButton.layer.cornerRadius = 8
        usernameLabel.text = UserManager.shared.getUsername() ?? "person.username.anonymous".localized
        personView.layer.cornerRadius = personView.frame.width / 2
        personView.clipsToBounds = true
        personView.layer.borderWidth = 1
        personView.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.3).cgColor
        personView.backgroundColor = .backgroundCard
        
        privacyView.layer.cornerRadius = 8
        privacyView.backgroundColor = UIColor.backgroundCard
        
        followedButton.layer.cornerRadius = followedButton.frame.height / 2
        followedButton.backgroundColor = .backgroundCard
        
        let more = UIImage(systemName: "line.3.horizontal")?.withTintColor(.textSecondary, renderingMode: .alwaysOriginal
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: more , style: .plain, target: self, action: #selector(moreButtonTapped))
        
        if personViewModel.isUserAnonymous() {
            followedButton.isEnabled = false
            addNewSocialButton.isEnabled = false
        }
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SocialCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "socialCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 60)
        
        collectionView.showAnimatedGradientSkeleton()
    }

    
    @IBAction func addNewSocialButtonTapped(_ sender: UIButton) {
        let editSocialVC: EditSocialViewController = Storyboard.editSocial.instantiate(.editSocial)
        editSocialVC.source = .addButton
        editSocialVC.viewModel = EditSocialViewModel(socialLinks: personViewModel.socialLinks?.links ?? [])
        navigationController?.pushViewController(editSocialVC, animated: true)
    }
    
    @objc private func moreButtonTapped() {
        let settingsVC = Storyboard.settings.instantiate(.settings)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func followedButtonTapped(_ sender: UIButton) {
        let followedVC: FollowChannelViewController = Storyboard.followChannel.instantiate(.followChannel)
        navigationController?.pushViewController(followedVC, animated: true)
    }
}

extension PersonViewController: PersonViewModelOutputProtocol, EmptyStateDisplayable {
    func didUpdateSocialLinks() {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
            self.hideEmptyState(from: self.collectionView)
            self.collectionView.reloadData()
        }
    }
    
    func didEmptySocialLinks() {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
            self.collectionView.reloadData()
            self.showEmptyState(type: .noSocialMediaLinks, in: self.collectionView)
        }
    }
    
    func didUserAnonymous() {
        self.collectionView.hideSkeleton()
    }
    
    func didFailSocialLinks(with error: any Error) {
        DispatchQueue.main.async {
            self.hideEmptyState(from: self.collectionView)
            self.collectionView.hideSkeleton()
            print(error)
        }
    }
}
