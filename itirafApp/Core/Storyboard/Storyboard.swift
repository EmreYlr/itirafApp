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
    case register = "Register"
    case chat = "Chat"
    case directMessage = "DirectMessage"
    case requestMessage = "RequestMessage"
    case editConfession = "EditConfession"
    case editSocial = "EditSocial"
    case settings = "Settings"
    case requestBottomSheet = "RequestBottomSheet"

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
    case channel = "ChannelViewController"
    case detail = "DetailViewController"
    case postConfession = "PostConfessionViewController"
    case person = "PersonViewController"
    case myConfessions = "MyConfessionsViewController"
    case myConfessionDetail = "MyConfessionDetailViewController"

    // Login.storyboard
    case login = "LoginViewController"
    
    // Register.storyboard
    case register = "RegisterViewController"
    
    // DirectMessage.storyboard
    case directMessage = "DirectMessageViewController"
    
    // Chat.storyboard
    case chat = "ChatViewController"
    
    // RequestMessage.storyboard
    case requestMessage = "RequestMessageViewController"
    
    // EditConfession.storyboard
    case editConfession = "EditConfessionViewController"
    
    // EditSocial.storyboard
    case editSocial = "EditSocialViewController"
    
    // Settings.storyboard
    case settings = "SettingsViewController"
    
    // RequestBottomSheet.storyboard
    case requestBottomSheet = "RequestBottomSheetViewController"
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
