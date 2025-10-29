//
//  EditConfessionViewController.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit

final class EditConfessionViewController: UIViewController {
    //MARK: - Properties
    
    var viewModel: EditConfessionViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EditConfessionViewController")
        initView()
    }
    
    private func initView() {
        navigationItem.title = "İtirafı Düzenle"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

}
