//
//  SettingsViewController.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import UIKit

final class SettingsViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var dataSource: UICollectionViewDiffableDataSource<SettingsSection, SettingItem>!
    var viewModel: SettingsViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = SettingsViewModel()
        super.init(coder: coder)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initUI() {
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.borderWidth = 0.2
        logoutButton.layer.borderColor = UIColor.textSecondary.cgColor
        navigationItem.title = "settings.title.main".localized
        
        configureCollectionViewLayout()
        configureDataSource()
        applySnapshot()
        
        collectionView.delegate = self
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func configureCollectionViewLayout() {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        config.backgroundColor = .backgroundApp
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)

            section.contentInsets.leading = 12
            section.contentInsets.trailing = 12
            
            return section
        }
        
        
        collectionView.collectionViewLayout = layout
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem> { (cell, indexPath, item) in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = UIImage(systemName: item.iconSystemName)
            
            content.textProperties.color = item.isEnabled ? .textPrimary : .tertiaryLabel
            content.imageProperties.tintColor = item.isEnabled ? .brandPrimary : .tertiaryLabel
            
            cell.isUserInteractionEnabled = item.isEnabled
            cell.accessories = item.isEnabled ? [.disclosureIndicator()] : []
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<SettingsSection, SettingItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            (headerView, elementKind, indexPath) in
            
            var config = UIListContentConfiguration.groupedHeader()
            config.text = SettingsSection(rawValue: indexPath.section)?.title
            headerView.contentConfiguration = config
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            }
            return nil
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingItem>()
        snapshot.appendSections([.profile, .account])
        let isAnonymous = viewModel.checkUserAnonymous()
        snapshot.appendItems(SettingItem.getProfileItems(isAnonymous: isAnonymous), toSection: .profile)
        snapshot.appendItems(SettingItem.getAccountItems(), toSection: .account)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func handleSelection(for itemType: SettingItem.ItemType) {
        switch itemType {
        case .editProfile:
            showEditProfileScreen()
        case .changePassword:
            print("Şifre Değiştir'e tıklandı")
        case .theme:
            showThemeSelection()
        case .privacyPolicy:
            print("Gizlilik Politikası'na tıklandı")
        case .aboutUs:
            print("Hakkımızda'ya tıklandı")
        case .notifications:
            showNotificationScreen()
        case .language:
            showLanguageSelection()
        }
    }
    
    private func showEditProfileScreen() {
        let editProfileVC: EditProfileViewController = Storyboard.editProfile.instantiate(.editProfile)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    private func showNotificationScreen() {
        let notificationVC: NotificationSettingsViewController = Storyboard.notificationSettings.instantiate(.notificationSettings)
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    private func showLanguageSelection() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func showThemeSelection() {
        let alert = UIAlertController(title: "theme.selection.title".localized, message: nil, preferredStyle: .actionSheet)
        
        let themes: [AppTheme] = [.device, .light, .dark]
        
        for theme in themes {
            let action = UIAlertAction(title: theme.title, style: .default) { _ in
                ThemeManager.shared.updateTheme(theme)
            }

            if theme == ThemeManager.shared.currentTheme {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "notification.button.cancel".localized, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        //TODO: Anoynmous çıkışına bi bak fazladan alert atıyor
        let performLogoutAction = {
            sender.isEnabled = false
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                await self.viewModel.logout()
            }
        }
        
        if viewModel.checkUserAnonymous() {
            performLogoutAction()
        } else {
            showTwoButtonAlert(
                title: "auth.logout.title".localized,
                message: "auth.logout.message.confirmation".localized,
                firstButtonTitle: "auth.button.logout".localized,
                firstButtonHandler: { _ in
                    performLogoutAction()
                }
            )
        }
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func didLogoutSuccessfully() {
        navigateToLogin()
    }
    
    func didFailToLogout(with error: any Error) {
        print(error)
        navigateToLogin()
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
