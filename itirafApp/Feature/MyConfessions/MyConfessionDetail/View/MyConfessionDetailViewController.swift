//
//  MyConfessionDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import UIKit

final class MyConfessionDetailViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rejectionReasonView: UIView!
    @IBOutlet weak var rejectionReasonLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var sendReplyButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var view3TopToView2Constraint: NSLayoutConstraint!
    @IBOutlet weak var view3TopToView1Constraint: NSLayoutConstraint!
    
    var viewModel: MyConfessionDetailViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MyConfessionDetailViewController")
        initData()
        initUI()
        loadCollectionView()
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
        statusView.layer.cornerRadius = statusView.frame.height / 2
        rejectionReasonView.layer.cornerRadius = 10
        rejectionReasonView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        messageView.layer.cornerRadius = 10
        messageView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        
        let deleteImage = UIImage(systemName: "trash.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: deleteImage , style: .done, target: self, action: #selector(deleteButtonTapped))
    }
    
    private func initData() {
        viewModel.delegate = self
        guard let myConfession = viewModel.myConfession else {
            return
        }
        switch viewModel.getModerationStatus() {
        case .approved:
            statusImageView.tintColor = .systemGreen
            statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.active".localized
            statusLabel.textColor = .systemGreen
            showRejectionReasonView(false)
            editButton.isHidden = true
        case .rejected:
            statusImageView.tintColor = .systemRed
            statusLabel.text = "confession.status.rejected".localized
            statusLabel.textColor = .systemRed
            statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            rejectionReasonView.isHidden = false
            rejectionReasonLabel.text = myConfession.rejectionReason ?? "confession.status.reason_not_specified".localized
            showRejectionReasonView(true)
            editButton.isHidden = false
        case .inReview:
            statusImageView.tintColor = .systemOrange
            statusLabel.textColor = .systemOrange
            statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.pending".localized
            showRejectionReasonView(false)
            editButton.isHidden = true
        case .unknown:
            statusImageView.tintColor = .systemGray
            statusLabel.textColor = .systemGray
            statusView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            statusLabel.text = "confession.status.unknown".localized
            showRejectionReasonView(false)
            editButton.isHidden = true
        }
        
        titleLabel.text = myConfession.title
        messageLabel.text = myConfession.message
        likeCountLabel.text = "\(myConfession.likeCount)"
        replyCountLabel.text = "\(myConfession.replyCount)"
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "DetailConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailConfessionCell")
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.frame.width
            flowLayout.estimatedItemSize = CGSize(width: width, height: 100)
        }
    }
    
    private func showRejectionReasonView(_ isVisible: Bool) {
        self.rejectionReasonView.isHidden = !isVisible
        self.view3TopToView2Constraint.isActive = isVisible
        self.view3TopToView1Constraint.isActive = !isVisible
    }
    
    
    @IBAction func sendReplyButtonTapped(_ sender: UIButton) {
        guard let commentText = replyTextField.text, !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

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
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let myConfession = viewModel.myConfession else {
            return
        }
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
