//
//  NotificationSettingsViewController.swift
//  itirafApp
//
//  Created by Emre on 17.11.2025.
//

import UIKit

final class NotificationSettingsViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var messageSwitch: UISwitch!
    @IBOutlet weak var replySwitch: UISwitch!
    @IBOutlet weak var likeSwitch: UISwitch!
    @IBOutlet weak var dmRequestSwitch: UISwitch!
    @IBOutlet weak var dmResponseSwitch: UISwitch!
    @IBOutlet weak var moderationSwitch: UISwitch!
    @IBOutlet weak var confessionSwitch: UISwitch!
    
    var viewModel: NotificationSettingsViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = NotificationSettingsViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupSwitchActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        viewModel.checkCurrentNotificationState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        if isMovingFromParent {
            Task {
                await viewModel.saveChangesIfAny()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initData() {
        viewModel.delegate = self
        navigationItem.title = "Bildirim Terchileri"
        
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
    
    private func setupSwitchActions() {
        let switches: [(UISwitch, NotificationPreferencesChannel)] = [
            (messageSwitch, .newDM),
            (replySwitch, .newReply),
            (likeSwitch, .newLike),
            (dmRequestSwitch, .dmRequest),
            (dmResponseSwitch, .dmRequestResponse),
            (moderationSwitch, .confessionModeration),
            (confessionSwitch, .newMessage)
        ]
        
        for (uiSwitch, channel) in switches {
            uiSwitch.addAction(UIAction { [weak self] action in
                guard let sender = action.sender as? UISwitch else { return }
                self?.viewModel.updateItemState(channel: channel, isOn: sender.isOn)
            }, for: .valueChanged)
        }
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
        stackView.isUserInteractionEnabled = isOn
        stackView.alpha = isOn ? 1.0 : 0.5
        if isOn {
            Task {
                await viewModel.getNotificationPreferences()
            }
        }
    }
    
    func reloadPreferences(items: [NotificationPreferencesItem]) {
        DispatchQueue.main.async {
            let pushItems = items.filter { $0.notificationType == .push }
            
            for item in pushItems {
                switch item.channel {
                case .newDM:
                    self.messageSwitch.setOn(item.enabled, animated: false)
                case .newReply:
                    self.replySwitch.setOn(item.enabled, animated: false)
                case .newLike:
                    self.likeSwitch.setOn(item.enabled, animated: false)
                case .dmRequest:
                    self.dmRequestSwitch.setOn(item.enabled, animated: false)
                case .dmRequestResponse:
                    self.dmResponseSwitch.setOn(item.enabled, animated: false)
                case .confessionModeration:
                    self.moderationSwitch.setOn(item.enabled, animated: false)
                case .newMessage:
                    self.confessionSwitch.setOn(item.enabled, animated: false)
                }
            }
        }
    }
    
    func didFailWithError(_ error: any Error) {
        print("Error fetching notification preferences: \(error)")
    }
}
