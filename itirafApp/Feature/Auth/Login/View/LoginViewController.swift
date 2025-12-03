//
//  LoginViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

final class LoginViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    private var loginViewModel: LoginViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.loginViewModel = LoginViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    private func initData() {
        loginViewModel.delegate = self
        navigationItem.title = "auth.title.login".localized
        
        let anonymousImage = UIImage(systemName: "person.crop.circle.fill.badge.questionmark")?.withTintColor(.textSecondary, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: anonymousImage , style: .done, target: self, action: #selector(anonymousButtonTapped))
        
        appleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.borderWidth = 0.7
        googleLoginButton.layer.borderColor = UIColor.textSecondary.cgColor
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.textSecondary.cgColor
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.textSecondary.cgColor
        
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
        sender.isEnabled = false
        do {
            guard let email = emailTextField.text, !email.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "auth.field.email"))
            }
            
            guard email.contains("@") else {
                throw ValidationError.invalidEmail
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "auth.field.password"))
            }
            
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                await loginViewModel.loginUser(
                    email: email,
                    password: password
                )
            }
        } catch {
            sender.isEnabled = true
            self.handleError(error)
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
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }

            guard let result = signInResult,
                  let idToken = result.user.idToken?.tokenString else {
                print("Google ID Token alınamadı.")
                return
            }

            let request = GoogleLoginRequest(
                idToken: idToken
            )

            Task(priority: .userInitiated) {
                await self.loginViewModel.loginWithGoogle(request: request)
            }
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
        DispatchQueue.main.async {
            let tabBarController: UITabBarController = Storyboard.main.instantiateTabBar(.mainTabBar)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }    
    }
    
    func didRequireEmailVerification(for email: String) {
        DispatchQueue.main.async {
            self.showTwoButtonAlert(title: "general.title.warning".localized, message: "message.account_not_verified".localized, firstButtonTitle: "error.send_resend".localized, firstButtonHandler: { _ in
                
                Task(priority: .utility) {
                    await self.loginViewModel.resendVerificationEmail(to: email)
                }
                
            }, secondButtonTitle: "general.button.cancel".localized)
        }   
    }
    
    func didFailToLogin(with error: Error) {
        DispatchQueue.main.async {
            if let apiError = error as? APIError {
                let refinedError = apiError.refinedForLogin()
                self.handleError(refinedError)
            } else {
                self.handleError(error)
            }
        }
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
            lastName: credential.fullName?.familyName
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
