//
//  NotificationSettingsViewController.swift
//  itirafApp
//
//  Created by Emre on 17.11.2025.
//

import UIKit

final class NotificationSettingsViewController: UIViewController {
    //MARK: - Properties
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationLabel: UILabel!
    var viewModel: NotificationSettingsViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = NotificationSettingsViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        viewModel.checkCurrentNotificationState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "Bildirim Ayarları"

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationRequestComplete),
            name: .didCompleteNotificationRequest,
            object: nil
        )
    }
    
    @objc private func handleAppWillEnterForeground() {
        viewModel.checkCurrentNotificationState()
    }
    
    @objc private func handleNotificationRequestComplete() {
        viewModel.checkCurrentNotificationState()
    }
    
    @IBAction func didTapNotificationSwitch(_ sender: UISwitch) {
        viewModel.handleSwitchTap()
    }
    
}

extension NotificationSettingsViewController: NotificationSettingsViewModelDelegate {
    func updateSwitchState(isOn: Bool) {
        notificationSwitch.setOn(isOn, animated: true)
    }
}
