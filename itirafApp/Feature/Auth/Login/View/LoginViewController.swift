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
    
    var loginViewModel: LoginViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.loginViewModel = LoginViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello")
        initData()
    }
    
    private func initData() {
        loginViewModel.delegate = self
        let anonymousImage = UIImage(systemName: "person.crop.circle.fill.badge.questionmark")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: anonymousImage , style: .done, target: self, action: #selector(anonymousButtonTapped))
        
        emailTextField.text = "ali@example.com"
        passwordTextField.text = "password123"
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registerViewController = Storyboard.register.instantiate(.register)
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showOneButtonAlert(
                title: "Hata",
                message: "Lütfen e-posta ve şifre alanlarını doldurun.",
                buttonTitle: "Tamam"
            )
            return
        }

        sender.isEnabled = false

        Task(priority: .utility) {
            defer {
                sender.isEnabled = true
            }
            await loginViewModel.loginUser(
                email: email,
                password: password
            )
        }
    }
    
    @objc private func anonymousButtonTapped() {
        Task(priority: .utility) {
            await loginViewModel.loginAnonymously()
        }
    }
}

extension LoginViewController: LoginViewModelOutputProtocol {
    func didLoginSuccessfully() {
        print("Login Başarılı")
        DispatchQueue.main.async {
            let tabBarController: UITabBarController = Storyboard.main.instantiateTabBar(.mainTabBar)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
        
    }
    
    func didFailToLogin(with error: Error) {
        print("Login Başarısız: \(error.localizedDescription)")
    }
}
