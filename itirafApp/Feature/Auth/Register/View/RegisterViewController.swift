//
//  RegisterViewController.swift
//  itirafApp
//
//  Created by Emre on 26.09.2025.
//

import UIKit
import SafariServices

final class RegisterViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    private var registerViewModel: RegisterViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.registerViewModel = RegisterViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupHideKeyboardOnTap()
        setupTextFieldDelegates()
        setupLabelGestures()
        updateRegisterButtonState()
    }
    
    private func initData() {
        registerViewModel.delegate = self
        navigationItem.title = "auth.title.register".localized
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.textSecondary.cgColor
        emailTextField.textContentType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.textSecondary.cgColor
        passwordTextField.isSecureTextEntry = true
        
        
        loginLabel.text = "register.already_account".localized
        loginButton.setTitle("auth.title.login".localized, for: .normal)
        
        let highlightPartTerms = "register_terms_part".localized
        let fullTextTerms = String(format: "register.read_approve".localized, highlightPartTerms)
        termsLabel.text = fullTextTerms
        termsLabel.highlight(targetString: highlightPartTerms, color: .brandPrimary)
        termsLabel.isUserInteractionEnabled = true
        
        let highlightPartPrivacy = "register_privacy_part".localized
        let fullTextPrivacy = String(format: "register.read_approve".localized, highlightPartPrivacy)
        privacyLabel.text = fullTextPrivacy
        privacyLabel.highlight(targetString: highlightPartPrivacy, color: .brandPrimary)
        privacyLabel.isUserInteractionEnabled = true
        
        privacySwitch.isOn = false
        termsSwitch.isOn = false
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupLabelGestures() {
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(handleTermsTap))
        termsLabel.addGestureRecognizer(termsTap)
        
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(handlePrivacyTap))
        privacyLabel.addGestureRecognizer(privacyTap)
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateRegisterButtonState() {
        let hasEmail = !(emailTextField.text?.isEmpty ?? true)
        let hasPassword = !(passwordTextField.text?.isEmpty ?? true)
        let termsAccepted = termsSwitch.isOn
        let privacyAccepted = privacySwitch.isOn
        
        let isFormValid = hasEmail && hasPassword && termsAccepted && privacyAccepted
        
        registerButton.isEnabled = isFormValid
        registerButton.alpha = isFormValid ? 1.0 : 0.5
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        updateRegisterButtonState()
    }
    
    @objc private func handleTermsTap() {
        guard let url = URL(string: registerViewModel.getTermsURL()) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .brandPrimary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }
    
    @objc private func handlePrivacyTap() {
        guard let url = URL(string: registerViewModel.getPrivacyURL()) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .brandPrimary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
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
            
            guard password.count >= 6 else {
                throw ValidationError.passwordTooShort(min: 6)
            }
            
            guard termsSwitch.isOn, privacySwitch.isOn else {
                return
            }
            
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                    hideLoading()
                }
                
                await registerViewModel.registerUser(
                    email: email,
                    password: password
                )
            }
        }
        catch {
            self.hideLoading()
            sender.isEnabled = true
            self.handleError(error)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func privacySwitchChanged(_ sender: UISwitch) {
        updateRegisterButtonState()
    }
    
    @IBAction func termsSwitchChanged(_ sender: UISwitch) {
        updateRegisterButtonState()
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
