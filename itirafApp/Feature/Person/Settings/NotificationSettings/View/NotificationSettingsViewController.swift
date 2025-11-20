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
        let switches: [(UISwitch, NotificationEventType)] = [
            (messageSwitch, .dmReceived),
            (replySwitch, .confessionReplied),
            (likeSwitch, .confessionLiked),
            (dmRequestSwitch, .dmRequestReceived),
            (dmResponseSwitch, .dmRequestResponded),
            (moderationSwitch, .confessionModerated),
            (confessionSwitch, .confessionPublished)
        ]
        
        for (uiSwitch, eventType) in switches {
            uiSwitch.addAction(UIAction { [weak self] action in
                guard let sender = action.sender as? UISwitch else { return }
                self?.viewModel.updateItemState(eventType: eventType, isOn: sender.isOn)
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
                switch item.eventType {
                case .dmReceived:
                    self.messageSwitch.setOn(item.enabled, animated: false)
                case .confessionReplied:
                    self.replySwitch.setOn(item.enabled, animated: false)
                case .confessionLiked:
                    self.likeSwitch.setOn(item.enabled, animated: false)
                case .dmRequestReceived:
                    self.dmRequestSwitch.setOn(item.enabled, animated: false)
                case .dmRequestResponded:
                    self.dmResponseSwitch.setOn(item.enabled, animated: false)
                case .confessionModerated:
                    self.moderationSwitch.setOn(item.enabled, animated: false)
                case .confessionPublished:
                    self.confessionSwitch.setOn(item.enabled, animated: false)
                case .adminReviewRequired:
                    continue
                case .unknown:
                    continue
                }
            }
        }
    }
    
    func didFailWithError(_ error: any Error) {
        print("Error fetching notification preferences: \(error)")
    }
}
