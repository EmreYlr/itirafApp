//
//  RegisterViewController.swift
//  itirafApp
//
//  Created by Emre on 26.09.2025.
//

import UIKit

final class RegisterViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private var registerViewModel: RegisterViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.registerViewModel = RegisterViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupHideKeyboardOnTap()
    }
    
    private func initData() {
        registerViewModel.delegate = self
        navigationItem.title = "auth.title.register".localized
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.textSecondary.cgColor
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.textSecondary.cgColor
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
            
            guard password.count >= 6 else {
                throw ValidationError.passwordTooShort(min: 6)
            }
            
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                
                await registerViewModel.registerUser(
                    email: email,
                    password: password
                )
            }
        }
        catch {
            sender.isEnabled = true
            self.handleError(error)
        }
    }
    
}

extension RegisterViewController: RegisterViewModelOutputProtocol {
    func didRegisterSuccessfully() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(
                title: String(localized: "auth.register.success.title"),
                message: String(localized: "auth.register.success.message"),
                buttonTitle: String(localized: "general.button.ok")
            ) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didRequireEmailVerification(for email: String) {
        DispatchQueue.main.async {
            self.showTwoButtonAlert(title: "general.title.warning".localized, message: "message.account_not_verified".localized, firstButtonTitle: "error.send_resend".localized, firstButtonHandler: { _ in
                
                Task(priority: .utility) {
                    await self.registerViewModel.resendVerificationEmail(to: email)
                }
                
            }, secondButtonTitle: "general.button.cancel".localized)
        }
    }
    
    func didFailToRegister(with error: Error) {
        DispatchQueue.main.async {
            if let apiError = error as? APIError {
                let refinedError = apiError.refinedForRegister()
                self.handleError(refinedError)
            } else {
                self.handleError(error)
            }
        }
    }
}
