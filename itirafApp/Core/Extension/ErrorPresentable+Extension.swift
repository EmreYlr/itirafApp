//
//  ErrorPresentable.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

import UIKit

extension ErrorPresentable where Self: UIViewController {
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            if let apiError = error as? APIError {
                self.handleAPIError(apiError)
            }
            else {
                self.showGenericAlert(title: "Hata", message: error.localizedDescription)
            }
        }
    }
    
    private func handleAPIError(_ error: APIError) {
        switch error.code {
            
        case 401:
            self.showAlertWithAction(
                title: "Oturum Süresi Doldu",
                message: "Lütfen tekrar giriş yapınız."
            ) {
                LoginAlertPresenter.showLoginAlert(from: self)
            }
            
        case 403:
            self.showGenericAlert(title: "Yetkisiz İşlem", message: "Bu işlemi yapmaya yetkiniz yok.")
            
        case 404:
            self.showGenericAlert(title: "Bulunamadı", message: "Aradığınız içerik silinmiş veya kaldırılmış.")
            
        case 500...599:
            self.showGenericAlert(title: "Sunucu Hatası", message: "Şu an sunucularımızda bir çalışma var. Lütfen daha sonra tekrar deneyin.")
            
        default:
            self.showGenericAlert(title: "Hata", message: error.message)
        }
    }
    
    // MARK: - Helper Functions

    private func showGenericAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
    
    private func showAlertWithAction(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default) { _ in
            completion()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
