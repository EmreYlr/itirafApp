//
//  PersonViewController.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

final class PersonViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var versionView: UIView!
    
    var personViewModel: PersonViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.personViewModel = PersonViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PersonViewController")
        initData()
    }
    
    func initData() {
        personViewModel.delegate = self
        versionView.layer.cornerRadius = 6
    }
    
    @IBAction func changeChannelButtonClicked(_ sender: UIButton) {
        let channelVC = Storyboard.channel.instantiate(.channel)
        channelVC.modalPresentationStyle = .pageSheet
        self.present(channelVC, animated: true)
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
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
    }
}

extension PersonViewController: PersonViewModelOutputProtocol {
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
