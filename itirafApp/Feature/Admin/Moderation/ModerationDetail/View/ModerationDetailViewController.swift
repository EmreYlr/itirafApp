//
//  ModerationDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationDetailViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var rejectionReasonLabel: UILabel!
    @IBOutlet weak var decisionSegmentControl: UISegmentedControl!
    @IBOutlet weak var violationsButton: UIButton!
    @IBOutlet weak var violationsLabel: UILabel!
    @IBOutlet weak var rejectPlaceholderLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var notePlaceholderLabel: UILabel!
    @IBOutlet weak var rejectTextView: UITextView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var rejectNoteLabel: UILabel!
    
    var viewModel: ModerationDetailViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ModerationDetailViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initData() {
        viewModel.delegate = self
        rejectTextView.delegate = self
        noteTextView.delegate = self
        
        guard let moderationItem = viewModel.moderationItem else { return }

        titleLabel.text = moderationItem.title
        messageLabel.text = moderationItem.message
        dateLabel.text = moderationItem.createdAt.formattedDateTime()
        ownerNameLabel.text = moderationItem.ownerUsername
        channelLabel.text = moderationItem.channelTitle
        rejectionReasonLabel.text = moderationItem.rejectionReason ?? "Belirtilmemiş"
        
        rejectTextView.isEditable = false
        rejectTextView.backgroundColor = UIColor.systemGray6
        rejectNoteLabel.isEnabled = false
        rejectPlaceholderLabel.isEnabled = false
        violationsButton.isEnabled = false
        violationsLabel.isHidden = false
    }
    
    private func initUI() {
        decisionSegmentControl.selectedSegmentIndex = 0
        decisionSegmentControl.selectedSegmentTintColor = UIColor.systemGreen.withAlphaComponent(0.4)
        
        violationsButton.layer.cornerRadius = 8
        violationsButton.layer.borderWidth = 0.2
        violationsButton.layer.borderColor = UIColor.systemGray4.cgColor
        
        buttonView.layer.borderWidth = 0.2
        buttonView.layer.borderColor = UIColor.systemGray4.cgColor
        
        saveButton.backgroundColor = .systemMint.withAlphaComponent(0.2)
        saveButton.layer.cornerRadius = 8
        
        rejectTextView.backgroundColor = UIColor.systemGray6
        rejectTextView.layer.cornerRadius = 6
        rejectTextView.layer.borderWidth = 0.5
        rejectTextView.layer.borderColor = UIColor.systemGray4.cgColor
        rejectTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        noteTextView.backgroundColor = UIColor.systemGray6
        noteTextView.layer.cornerRadius = 6
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = UIColor.systemGray4.cgColor
        noteTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        updateViolationsLabel()
    }
    
    private func updateViolationsLabel() {
        if viewModel.selectedViolations.isEmpty {
            violationsLabel.isHidden = true
        } else {
            violationsLabel.isHidden = false
            let descriptions = viewModel.selectedViolations.map { $0.turkishDescription }
            violationsLabel.text = "(\(descriptions.joined(separator: ", ")))"
            violationsLabel.textColor = .systemGray
        }
    }
    
    @IBAction func decisionSegmentControlChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentTintColor = sender.selectedSegmentIndex == 0 ? UIColor.systemGreen.withAlphaComponent(0.4) : UIColor.systemRed.withAlphaComponent(0.4)
        
        let isApproving = sender.selectedSegmentIndex == 0
        
        rejectTextView.isEditable = !isApproving
        rejectTextView.backgroundColor = isApproving ? UIColor.systemGray5 : UIColor.systemGray6
        rejectNoteLabel.isEnabled = !isApproving
        rejectPlaceholderLabel.isEnabled = !isApproving
        violationsButton.isEnabled = !isApproving
        violationsLabel.isHidden = isApproving || viewModel.selectedViolations.isEmpty
    }
    
    @IBAction func violationsButtonTapped(_ sender: UIButton) {
        let violationsVC: ViolationsViewController = Storyboard.moderation.instantiate(.violations)
        violationsVC.delegate = self
        violationsVC.selectedViolations = viewModel.selectedViolations
        let navigationController = UINavigationController(rootViewController: violationsVC)

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) { }
    
}

extension ModerationDetailViewController: ModerationDetailViewModelDelegate {
    func didPostDecisionSuccessfully() {
        
    }
    
    func didFailPostingDecision(_ error: any Error) {
        print("Error posting decision: \(error)")
    }
}

extension ModerationDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == noteTextView {
            notePlaceholderLabel.isHidden = !noteTextView.text.isEmpty
        } else if textView == rejectTextView {
            rejectPlaceholderLabel.isHidden = !rejectTextView.text.isEmpty
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == noteTextView {
            notePlaceholderLabel.isHidden = true
            noteTextView.layer.borderColor = UIColor.systemMint.cgColor
            
        } else if textView == rejectTextView {
            rejectPlaceholderLabel.isHidden = true
            rejectTextView.layer.borderColor = UIColor.systemMint.cgColor
        }

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView {
            noteTextView.layer.borderColor = UIColor.lightGray.cgColor
            
        } else if textView == rejectTextView {
            rejectTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}

extension ModerationDetailViewController: ViolationsViewControllerDelegate {
    func didSelectViolations(_ violations: [Violation]) {
        viewModel.selectedViolations = violations
        updateViolationsLabel()
    }
}
