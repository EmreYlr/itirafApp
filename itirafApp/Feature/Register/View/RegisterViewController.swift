//
//  RegisterViewController.swift
//  itirafApp
//
//  Created by Emre on 26.09.2025.
//

import UIKit

final class RegisterViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
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

    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) { }
    
}
