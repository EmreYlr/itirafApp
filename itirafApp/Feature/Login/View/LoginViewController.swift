//
//  LoginViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit

final class LoginViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Hello")
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) { }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let tabBarController: UITabBarController = Storyboard.main.instantiateTabBar(.mainTabBar)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        } else {
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true)
        }

    }
}
