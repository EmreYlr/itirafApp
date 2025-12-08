//
//  LoadingDisplayable.swift
//  itirafApp
//
//  Created by Emre on 8.12.2025.
//

import UIKit

enum LoadingStyle {
    case fullScreenDimmed
    case fullScreenClear
    case localDimmed
}

protocol LoadingDisplayable {
    func showLoading(style: LoadingStyle)
    func hideLoading()
}

fileprivate let loadingViewTag = 1327

extension LoadingDisplayable where Self: UIViewController {
    private var activeWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
    }
    
    func showLoading(style: LoadingStyle = .fullScreenDimmed) {
        DispatchQueue.main.async {
            let window = self.activeWindow
            
            if self.view.viewWithTag(loadingViewTag) != nil ||
                window?.viewWithTag(loadingViewTag) != nil {
                return
            }
            
            let loadingView = self.createLoadingView(style: style)
            loadingView.tag = loadingViewTag
            
            if style == .localDimmed {
                loadingView.frame = self.view.bounds
                self.view.addSubview(loadingView)
            } else {
                if let targetWindow = window {
                    loadingView.frame = targetWindow.bounds
                    targetWindow.addSubview(loadingView)
                }
            }
            
            loadingView.alpha = 0
            UIView.animate(withDuration: 0.25) {
                loadingView.alpha = 1
            }
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            let windowView = self.activeWindow?.viewWithTag(loadingViewTag)
            let localView = self.view.viewWithTag(loadingViewTag)
            
            if let viewToRemove = windowView ?? localView {
                UIView.animate(withDuration: 0.25, animations: {
                    viewToRemove.alpha = 0
                }) { _ in
                    viewToRemove.removeFromSuperview()
                }
            }
        }
    }
    
    private func createLoadingView(style: LoadingStyle) -> UIView {
        let container = UIView()
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        switch style {
        case .fullScreenDimmed, .localDimmed:
            container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case .fullScreenClear:
            container.backgroundColor = .clear
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        container.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
}

extension UIViewController: LoadingDisplayable {}
