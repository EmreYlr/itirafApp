//
//  PersonViewController.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import UIKit

final class PersonViewController: UIViewController {
    //MARK: - Properties
    
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
    }
    
    @IBAction func changeChannelButtonClicked(_ sender: UIButton) {
        let channelVC = Storyboard.channel.instantiate(.channel)
        navigationController?.pushViewController(channelVC, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        personViewModel.logout()
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
