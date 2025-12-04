//
//  ModerationDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import UIKit

final class ModerationDetailViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var scrollView: UIScrollView!
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
    @IBOutlet weak var rejectView: UIView!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var nsfwView: UIView!
    var viewModel: ModerationDetailViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = ModerationDetailViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        setupHideKeyboardOnTap()
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
        rejectionReasonLabel.text = moderationItem.rejectionReason ?? "moderation.detail.reason.unspecified".localized
        nsfwSwitch.isOn = moderationItem.isNsfw
    }
    
    private func initUI() {
        decisionSegmentControl.selectedSegmentIndex = 0
        decisionSegmentControl.selectedSegmentTintColor = UIColor.statusSuccess.withAlphaComponent(0.4)
        
        violationsButton.layer.cornerRadius = 8
        violationsButton.layer.borderWidth = 0.2
        violationsButton.layer.borderColor = UIColor.textSecondary.cgColor
        
        buttonView.layer.borderWidth = 0.2
        buttonView.layer.borderColor = UIColor.textSecondary.cgColor
        
        saveButton.backgroundColor = .brandSecondary.withAlphaComponent(0.2)
        saveButton.layer.cornerRadius = 8
        
        rejectTextView.backgroundColor = UIColor.backgroundCard
        rejectTextView.layer.cornerRadius = 6
        rejectTextView.layer.borderWidth = 0.5
        rejectTextView.layer.borderColor = UIColor.textSecondary.cgColor
        rejectTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        noteTextView.backgroundColor = UIColor.backgroundCard
        noteTextView.layer.cornerRadius = 6
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.borderColor = UIColor.textSecondary.cgColor
        noteTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        updateViolationsLabel()

        segmentUpdateUI(segmentValue: true)
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func updateViolationsLabel() {
        if viewModel.selectedViolations.isEmpty {
            violationsLabel.isHidden = true
        } else {
            violationsLabel.isHidden = false
            let descriptions = viewModel.selectedViolations.map { $0.description }
            violationsLabel.text = "(\(descriptions.joined(separator: ", ")))"
            violationsLabel.textColor = .textSecondary
        }
    }
    
    private func segmentUpdateUI(segmentValue: Bool) {
        if segmentValue {
            rejectView.isHidden = segmentValue
            nsfwView.isHidden = !segmentValue
        } else {
            rejectView.isHidden = segmentValue
            nsfwView.isHidden = !segmentValue
        }
    }
    
    @IBAction func decisionSegmentControlChanged(_ sender: UISegmentedControl) {
        let isApproving = sender.selectedSegmentIndex == 0
        
        sender.selectedSegmentTintColor = isApproving ?
        UIColor.statusSuccess.withAlphaComponent(0.4) :
        UIColor.statusError.withAlphaComponent(0.4)
        
        UIView.animate(withDuration: 0.3) {
            self.segmentUpdateUI(segmentValue: isApproving)
            self.view.layoutIfNeeded()
        }
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
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let isApproving = decisionSegmentControl.selectedSegmentIndex == 0
        let decision: ModerationDecision = isApproving ? .approve : .reject
        let notes = noteTextView.text.isEmpty ? nil : noteTextView.text

        var reason: String?
        var violations: [Violation]?
        var isNsfw: Bool
        
        if isApproving {
            reason = nil
            violations = nil
            isNsfw = nsfwSwitch.isOn
        } else {
            reason = rejectTextView.text.isEmpty ? nil : rejectTextView.text
            violations = viewModel.selectedViolations.isEmpty ? nil : viewModel.selectedViolations
            isNsfw = false
        }
        
        Task(priority: .utility) {
            await viewModel.postDecision(
                decision: decision,
                reason: reason,
                violations: violations,
                notes: notes,
                isNsfw: isNsfw
            )
        }
    }
}

extension ModerationDetailViewController: ModerationDetailViewModelDelegate {
    func didPostDecisionSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func didFailPostingDecision(_ error: any Error) {
        DispatchQueue.main.async { [weak self] in
            self?.handleError(error)
        }
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
            noteTextView.layer.borderColor = UIColor.textSecondary.cgColor
            
        } else if textView == rejectTextView {
            rejectPlaceholderLabel.isHidden = true
            rejectTextView.layer.borderColor = UIColor.textSecondary.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)

            if bottomOffset.y > 0 {
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView {
            noteTextView.layer.borderColor = UIColor.divider.cgColor
            
        } else if textView == rejectTextView {
            rejectTextView.layer.borderColor = UIColor.divider.cgColor
        }
    }
}

extension ModerationDetailViewController: ViolationsViewControllerDelegate {
    func didSelectViolations(_ violations: [Violation]) {
        viewModel.selectedViolations = violations
        updateViolationsLabel()
    }
}
