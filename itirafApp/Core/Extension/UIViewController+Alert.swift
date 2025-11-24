//
//  Alert.swift
//  itirafApp
//
//  Created by Emre on 8.10.2025.
//

import UIKit

extension UIViewController {
    func showOneButtonAlert(title: String, message: String, buttonTitle: String = "general.button.ok".localized, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showTwoButtonAlert(title: String, message: String, firstButtonTitle: String = "general.button.ok".localized, firstButtonHandler: ((UIAlertAction) -> Void)? = nil, secondButtonTitle: String = "general.button.cancel".localized, secondButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default, handler: firstButtonHandler)
        let secondAction = UIAlertAction(title: secondButtonTitle, style: .cancel, handler: secondButtonHandler)
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
