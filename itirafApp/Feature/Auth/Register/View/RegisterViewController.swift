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
    
    var registerViewModel: RegisterViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.registerViewModel = RegisterViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RegisterViewController")
        registerViewModel.delegate = self
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !email.isEmpty, !password.isEmpty else {
            showOneButtonAlert(
                title: "Eksik Bilgi",
                message: "Lütfen tüm alanları doldurun.",
                buttonTitle: "Tamam"
            )
            return
        }
        
        sender.isEnabled = false
        
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
    
}

extension RegisterViewController: RegisterViewModelOutputProtocol {
    func didRegisterSuccessfully() {
        print("Registration Successful")
        DispatchQueue.main.async {
            self.showOneButtonAlert(
                title: "Kayıt Başarılı",
                message: "Hesabınız başarıyla oluşturuldu. Giriş yapabilirsiniz.",
                buttonTitle: "Tamam"
            ) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didFailToRegister(with error: Error) {
        print("Registration Failed: \(error.localizedDescription)")
    }
    
}
