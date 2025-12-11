//
//  EditConfessionViewController.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import UIKit

final class EditConfessionViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var rejectionReasonLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: EditConfessionViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initView() {
        navigationItem.title = "confession.title.edit_confession".localized
        statusView.layer.cornerRadius = statusView.frame.height / 2
        statusView.backgroundColor = UIColor.statusError.withAlphaComponent(0.2)
        reportView.layer.cornerRadius = 10
        reportView.backgroundColor = UIColor.statusError.withAlphaComponent(0.1)
        
        detailTextView.delegate = self
        titleTextField.delegate = self
        
        detailTextView.layer.borderColor = UIColor.textSecondary.cgColor
        detailTextView.layer.borderWidth = 1
        detailTextView.layer.cornerRadius = 6
        
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.borderColor = UIColor.textSecondary.cgColor
        
        let deleteImage = UIImage(systemName: "trash.fill")?.withTintColor(.statusError)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: deleteImage , style: .plain, target: self, action: #selector(deleteButtonTapped))
    }
    
    private func initData() {
        viewModel.delegate = self
        
        let myConfession = viewModel.myConfession
        let mainReason = myConfession.rejectionReason ?? ""
        
        var violationText = ""
        if let violations = myConfession.violations, !violations.isEmpty {
            let description = violations.map { $0.description }
            
            let joinedViolations = description.joined(separator: ", ")
            
            violationText = " (\(joinedViolations))"
        }

        rejectionReasonLabel.text = mainReason + violationText
        titleTextField.text = myConfession.title
        detailTextView.text = myConfession.message
    }
    
    @objc private func deleteButtonTapped() {
        showTwoButtonAlert(title: "general.title.warning".localized, message: "confession.message.delete_confirmation".localized, firstButtonTitle: "general.button.yes".localized, firstButtonHandler: { _ in
            self.showLoading()
            Task(priority: .utility) {
                defer {
                    self.hideLoading()
                }
                await self.viewModel.deleteConfession()
            }
        }, secondButtonTitle: "general.button.cancel".localized, secondButtonHandler: nil)
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        showLoading()
        sender.isEnabled = false
        do {
            let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let detailText = detailTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            guard !titleText.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "confession.field.title"))
            }
            
            guard !detailText.isEmpty else {
                throw ValidationError.emptyField(fieldName: String(localized: "confession.field.description"))
            }
            
            Task(priority: .utility) {
                defer {
                    hideLoading()
                    sender.isEnabled = true
                }
                await viewModel.editConfession(title: titleText, message: detailText)
            }
            
        } catch {
            self.hideLoading()
            sender.isEnabled = true
            self.handleError(error)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension EditConfessionViewController: EditConfessionViewModelDelegate {
    func didDeleteConfession() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "general.title.success".localized, message: "confession.success.message.deleted".localized, buttonTitle: "general.button.ok".localized) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didUpdateConfession() {
        DispatchQueue.main.async { [weak self] in
            self?.showOneButtonAlert(title: "general.title.success".localized, message: "confession.success.message.updated".localized, buttonTitle: "general.button.ok".localized) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didError(error: any Error) {
        DispatchQueue.main.async { [weak self] in
            self?.handleError(error)
        }
    }
}

extension EditConfessionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        detailTextView.layer.borderColor = UIColor.textSecondary.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        detailTextView.layer.borderColor = UIColor.divider.cgColor
    }
}

extension EditConfessionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextField.layer.borderColor = UIColor.textSecondary.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextField.layer.borderColor = UIColor.divider.cgColor
    }
    
}
