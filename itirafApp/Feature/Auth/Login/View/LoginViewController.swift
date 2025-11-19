//
//  LoginViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
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
        
        appleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.borderWidth = 0.7
        googleLoginButton.layer.borderColor = UIColor.systemGray4.cgColor
        
        emailTextField.text = "ali@example.com"
        passwordTextField.text = "password123"
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let registerViewController = Storyboard.register.instantiate(.register)
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction func forgotPasswordButonTapped(_ sender: UIButton) {
        let forgotPasswordVC = Storyboard.forgotPassword.instantiate(.forgotPassword)
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
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
    
    @IBAction func appleLoginButtonTapped(_ sender: UIButton) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
        
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

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else { return }
        
        let request = AppleLoginRequest(
            identityToken: tokenString,
            firstName: credential.fullName?.givenName,
            lastName: credential.fullName?.familyName,
            email: credential.email
        )

        Task(priority: .userInitiated) {
            await loginViewModel.loginWithApple(request: request)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Login Error: \(error.localizedDescription)")
    }
}

// MARK: - Apple Sign In Presentation Context
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
