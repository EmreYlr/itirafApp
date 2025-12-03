//
//  ModerationDetailBottomSheetViewController.swift
//  itirafApp
//
//  Created by Emre on 30.11.2025.
//

import UIKit

final class ModerationDetailBottomSheetViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var decisionSegmentControl: UISegmentedControl!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var nsfwView: UIView!
    @IBOutlet weak var violationsLabel: UILabel!
    @IBOutlet weak var violationsButton: UIButton!
    @IBOutlet weak var rejectPlaceholderLabel: UILabel!
    @IBOutlet weak var rejectTextView: UITextView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var rejectView: UIView!
    
    var viewModel: ModerationDetailBottomSheetViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    private func initUI() {
        navigationItem.title = "moderation.detail_bottom_sheet.title".localized
        
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
        
        updateViolationsLabel()

        segmentUpdateUI(segmentValue: true)
    }
    
    private func initData() {
        viewModel.delegate = self
        rejectTextView.delegate = self
        nsfwSwitch.isOn = viewModel.actionModel.isNSFW
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
    
    @IBAction func decisionSegmentChanged(_ sender: UISegmentedControl) {
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
        sender.isEnabled = false
        
        let isApproving = decisionSegmentControl.selectedSegmentIndex == 0
        let decision: ModerationDecision = isApproving ? .approve : .reject

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
            defer {
                DispatchQueue.main.async {
                    sender.isEnabled = true
                }
            }
            await viewModel.editAdminConfession(
                decision: decision,
                reason: reason,
                violations: violations,
                isNsfw: isNsfw
            )
        }
    }
}

extension ModerationDetailBottomSheetViewController: ModerationDetailBottomSheetViewModelDelegate {
    func didEditSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func didError(_ error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}

extension ModerationDetailBottomSheetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        rejectPlaceholderLabel.isHidden = !rejectTextView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        rejectPlaceholderLabel.isHidden = true
        rejectTextView.layer.borderColor = UIColor.textSecondary.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        rejectTextView.layer.borderColor = UIColor.divider.cgColor
    }
}
extension ModerationDetailBottomSheetViewController: ViolationsViewControllerDelegate {
    func didSelectViolations(_ violations: [Violation]) {
        viewModel.selectedViolations = violations
        updateViolationsLabel()
    }
}
