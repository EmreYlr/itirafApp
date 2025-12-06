//
//  MyConfessionDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import UIKit

final class MyConfessionDetailViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var sendReplyButton: UIButton!
    
    var viewModel: MyConfessionDetailViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        loadCollectionView()
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
    
    private func initUI() {
        replyTextField.layer.cornerRadius = 20
        replyTextField.layer.borderColor = UIColor.textSecondary.cgColor
        replyTextField.layer.borderWidth = 0.3
        replyTextField.clipsToBounds = true
        replyTextField.layer.cornerCurve = .continuous
        replyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let deleteImage = UIImage(systemName: "trash.fill")?.withTintColor(.statusError)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: deleteImage , style: .plain, target: self, action: #selector(deleteButtonTapped))
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "MyConfessionHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myconfesionHeaderCell")
        
        collectionView.register(UINib(nibName: "DetailConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailConfessionCell")
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 100)
    }
    
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendReplyButtonTapped(_ sender: UIButton) {
        guard let commentText = replyTextField.text, !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        sender.isEnabled = false
        replyTextField.isEnabled = false
        
        Task(priority: .utility) {
            defer {
                sender.isEnabled = true
                replyTextField.isEnabled = true
            }
            await viewModel.addComment(message: commentText)
            replyTextField.text = ""
            replyTextField.resignFirstResponder()
        }
    }
    
    func handleEditConfession() {
        guard let myConfession = viewModel.myConfession else { return }
        
        let editVC: EditConfessionViewController = Storyboard.editConfession.instantiate(.editConfession)
        editVC.viewModel = EditConfessionViewModel(myConfession: myConfession)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        showTwoButtonAlert(title: "general.title.warning".localized, message: "confession.message.delete_confirmation".localized, firstButtonTitle: "general.button.yes".localized, firstButtonHandler: { _ in
            Task(priority: .utility) {
                await self.viewModel.deleteConfession()
            }
        }, secondButtonTitle: "general.button.cancel".localized, secondButtonHandler: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let maxCount = viewModel.getMaxReplyCharacterCount()
        
        guard let text = textField.text else { return }
        
        if text.count > maxCount {
            textField.text = String(text.prefix(maxCount))
            
            textField.layer.borderColor = UIColor.statusError.cgColor
            return
        }
        
        if text.count == maxCount {
            textField.layer.borderColor = UIColor.statusError.cgColor
        } else {
            textField.layer.borderColor = UIColor.textSecondary.cgColor
        }
    }
}

extension MyConfessionDetailViewController: MyConfessionDetailViewModelDelegate {
    func didUpdateReplies() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func didDeleteConfession() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func didError(error: any Error) {
        DispatchQueue.main.async {
            self.handleError(error)
        }
    }
}

extension MyConfessionDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == replyTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= viewModel.getMaxReplyCharacterCount()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        replyTextField.layer.borderColor = UIColor.textSecondary.cgColor
    }
}
