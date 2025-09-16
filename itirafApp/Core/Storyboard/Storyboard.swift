//
//  Storyboard.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

import UIKit

enum Storyboard: String {
    case main = "Main"
    case login = "Login"

    var instance: UIStoryboard {
        UIStoryboard(name: self.rawValue, bundle: nil)
    }

    func instantiate<T: UIViewController>(_ vc: ViewControllerID) -> T {
        guard let vc = instance.instantiateViewController(withIdentifier: vc.rawValue) as? T else {
            fatalError("Couldn't instantiate \(vc.rawValue) from \(self.rawValue)")
        }
        return vc
    }
    
    func instantiateNav<T: UINavigationController>(_ nav: NavigationControllerID) -> T {
        guard let navVC = instance.instantiateViewController(withIdentifier: nav.rawValue) as? T else {
            fatalError("Couldn't instantiate \(nav.rawValue) from \(self.rawValue)")
        }
        return navVC
    }
    
    func instantiateTabBar<T: UITabBarController>(_ tabBar: TabBarID) -> T {
        guard let tabBarVC = instance.instantiateViewController(withIdentifier: tabBar.rawValue) as? T else {
            fatalError("Couldn't instantiate \(tabBar.rawValue) from \(self.rawValue)")
        }
        return tabBarVC
    }
}

enum ViewControllerID: String {
    // Main.storyboard
    case home = "HomeViewController"
    case detail = "DetailViewController"

    // Login.storyboard
    case login = "LoginViewController"
    case register = "RegisterViewController"
}

enum NavigationControllerID: String {
    // Main.storyboard
    case homeNav = "HomeNavigationController"
    
    // Login.storyboard
    case loginNav = "LoginNavigationController"
}

enum TabBarID: String {
    case mainTabBar = "RootTabBarController"
}
