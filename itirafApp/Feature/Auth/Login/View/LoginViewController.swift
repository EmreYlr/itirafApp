//
//  LoginViewController.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import AuthenticationServices
import GoogleSignIn
import SafariServices

final class LoginViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var anonymousLoginButton: UIButton!
    @IBOutlet weak var eulaLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    private var termsRange: NSRange?
    private var privacyRange: NSRange?

    private var loginViewModel: LoginViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.loginViewModel = LoginViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupHideKeyboardOnTap()
    }
    
    private func initData() {
        loginViewModel.delegate = self
        navigationItem.title = "auth.title.login".localized
        
        registerLabel.text = "login.dont_account".localized
        registerButton.setTitle("auth.title.register".localized, for: .normal)
        
        setupLegalLabel()
        
        appleLoginButton.layer.cornerRadius = 8
        appleLoginButton.layer.borderWidth = 0.7
        appleLoginButton.layer.borderColor = UIColor.textSecondary.cgColor
        
        googleLoginButton.layer.cornerRadius = 8
        googleLoginButton.layer.borderWidth = 0.7
        googleLoginButton.layer.borderColor = UIColor.textSecondary.cgColor
        
        anonymousLoginButton.layer.cornerRadius = 8
        anonymousLoginButton.layer.borderWidth = 0.7
        anonymousLoginButton.layer.borderColor = UIColor.textSecondary.cgColor
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.textSecondary.cgColor
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.textSecondary.cgColor
    }
    
    private func setupLegalLabel() {
        let termsText = "auth.legal.terms".localized
        let privacyText = "auth.legal.privacy".localized
        let fullText = String(format: "auth.legal.full_text".localized, termsText, privacyText)
        
        let attributedString = NSMutableAttributedString(string: fullText)

        attributedString.addAttribute(.foregroundColor, value: UIColor.textSecondary, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: fullText.count))

        let linkAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.textPrimary
        ]

        let nsString = fullText as NSString
        termsRange = nsString.range(of: termsText)
        privacyRange = nsString.range(of: privacyText)

        if let termsRange = termsRange {
            attributedString.addAttributes(linkAttributes, range: termsRange)
        }
        
        if let privacyRange = privacyRange {
            attributedString.addAttributes(linkAttributes, range: privacyRange)
        }
        
        eulaLabel.attributedText = attributedString
        eulaLabel.isUserInteractionEnabled = true
        eulaLabel.numberOfLines = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
        eulaLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let text = eulaLabel.attributedText?.string else { return }
        let tapLocation = gesture.location(in: eulaLabel)
        let index = eulaLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if index >= 0 && index < text.count {
            if let termsRange = termsRange, NSLocationInRange(index, termsRange) {
                print("Kullanıcı Sözleşmesi'ne tıklandı")
                openURLSafari(isTerms: true)
            } else if let privacyRange = privacyRange, NSLocationInRange(index, privacyRange) {
                print("Gizlilik Politikası'na tıklandı")
                openURLSafari(isTerms: false)
            }
        }
    }
    
    private func openURLSafari(isTerms: Bool) {
        guard let url = URL(string: loginViewModel.getTermsOrPrivacyURL(isTerms: isTerms)) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .brandPrimary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        showLoading()
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
                    self.hideLoading()
                }
                await loginViewModel.loginUser(
                    email: email,
                    password: password
                )
            }
        } catch {
            self.hideLoading()
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
            self.showLoading()
            
            Task(priority: .userInitiated) {
                defer {
                    self.hideLoading()
                }
                await self.loginViewModel.loginWithGoogle(request: request)
            }
        }
    }
    
    
    @IBAction func anonymousLoginButtonTapped(_ sender: UIButton) {
        showLoading()
        
        Task(priority: .utility) {
            defer {
                self.hideLoading()
            }
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
        self.showLoading()
        
        Task(priority: .userInitiated) {
            defer {
                self.hideLoading()
            }
            
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
