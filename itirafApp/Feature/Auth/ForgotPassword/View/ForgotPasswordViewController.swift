//
//  ForgotPasswordViewController.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//

import UIKit

final class ForgotPasswordViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var viewModel: ForgotPasswordViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ForgotPasswordViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    private func initData() {
        navigationItem.title = "auth.title.forgot_password".localized
        viewModel.delegate = self
        emailTextField.delegate = self
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        do {
            guard let email = emailTextField.text, !email.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "auth.field.email"))
            }
            guard email.contains("@") else {
                throw ValidationError.invalidEmail
            }
            
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                }
                await viewModel.resetPassword(email: email)
            }
            
        } catch {
            sender.isEnabled = true
            self.handleError(error)
        }
    }
}

extension ForgotPasswordViewController: ForgotPasswordViewModelDelegate {
    func didResetPasswordSuccessfully() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: "success.title".localized, message: "auth.forgot_password.success.message".localized) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didFailToResetPassword(with error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextField.layer.borderColor = UIColor.systemMint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
}
