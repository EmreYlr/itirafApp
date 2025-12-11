//
//  ReportViewController.swift
//  itirafApp
//
//  Created by Emre on 11.12.2025.
//

import UIKit

final class ReportViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var reportDetailTitleLabel: UILabel!
    @IBOutlet weak var reportDetailDescriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var viewModel: ReportViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initView()
    }
    
    private func initData() {
        viewModel.delegate = self
        
        reportDetailTitleLabel.text = "report.detail_title".localized
        reportDetailDescriptionLabel.text = "report.detail_description".localized
        warningLabel.text = "report.warning_text".localized
        placeholderLabel.text = "report.detail_placeholder".localized
        submitButton.setTitle("report.submit_button".localized, for: .normal)
    }
    
    private func initView() {
        reportTextView.delegate = self
        reportTextView.layer.borderColor = UIColor.divider.cgColor
        reportTextView.layer.borderWidth = 1
        reportTextView.layer.cornerRadius = 6
        reportTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        warningView.layer.cornerRadius = 6
        warningView.backgroundColor = .brandPrimary.withAlphaComponent(0.2)

        submitButton.layer.cornerRadius = 8
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        updateCharacterCountLabel()
    }
    
    private func updateCharacterCountLabel() {
        let maxCharacterCount = viewModel.getContentCharrecterCount()
        
        let currentCount = reportTextView.text.count
        let remaining = maxCharacterCount - currentCount
        
        countLabel.text = "post.content_remaining".localized(remaining)
        
        if remaining == 0 {
            countLabel.textColor = .statusError
            reportTextView.layer.borderColor = UIColor.statusError.cgColor
        } else {
            countLabel.textColor = .textTertiary
            if reportTextView.isFirstResponder {
                reportTextView.layer.borderColor = UIColor.textSecondary.cgColor
            } else {
                reportTextView.layer.borderColor = UIColor.divider.cgColor
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        showLoading()
        sender.isEnabled = false
        do {
            guard let reportContent = reportTextView.text, !reportContent.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "report.field.content"))
            }
            Task(priority: .utility) {
                defer {
                    sender.isEnabled = true
                    self.hideLoading()
                }
                await viewModel.submitReport(reason: reportContent)
            }
        } catch {
            self.hideLoading()
            sender.isEnabled = true
            self.handleError(error)
        }
    }
}

extension ReportViewController: ReportViewModelDelegate {
    func didSubmitReport() {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: "general.title.success".localized, message: "report.message_success".localized) { _ in
                self.dismiss(animated: true)
            }
        }
    }
    
    func didFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            if let apiError = error as? APIError {
                let refinedError = apiError.refinedForBuisness()
                self.handleError(refinedError)
            } else {
                self.handleError(error)
            }
        }
    }
}

extension ReportViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= viewModel.getContentCharrecterCount()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !reportTextView.text.isEmpty
        
        updateCharacterCountLabel()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateCharacterCountLabel()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateCharacterCountLabel()
    }
}
