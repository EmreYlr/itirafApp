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
        emailTextField.text = "ali@gmail.com"
        passwordTextField.text = "12345678"
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

        Task {
            defer {
                sender.isEnabled = true
            }
            await loginViewModel.loginUser(
                email: email,
                password: password
            )
        }
    }
}

extension LoginViewController: LoginViewModelOutputProtocol {
    func didLoginSuccessfully() {
        print("Login Başarılı")
        let tabBarController: UITabBarController = Storyboard.main.instantiateTabBar(.mainTabBar)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func didFailToLogin(with error: Error) {
        print("Login Başarısız: \(error.localizedDescription)")
    }
}
