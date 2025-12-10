//
//  DetailViewController.swift
//  itirafApp
//
//  Created by Emre on 30.09.2025.
//

import UIKit
import SkeletonView

final class DetailViewController: UIViewController {
    //MARK: -Rroperties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var replyView: UIView!
    
    var detailViewModel: DetailViewModelProtocol!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        loadCollectionView()
        setupHideKeyboardOnTap()
    }

    private func initUI() {
        replyTextField.layer.cornerRadius = 20
        replyTextField.layer.borderColor = UIColor.textSecondary.cgColor
        replyTextField.layer.borderWidth = 0.3
        replyTextField.clipsToBounds = true
        replyTextField.layer.cornerCurve = .continuous
        
        replyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func initData() {
        detailViewModel.delegate = self
        Task {
            await detailViewModel.fetchMessageData()
        }
    }

    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "DetailHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailHeaderCell")
        
        collectionView.register(UINib(nibName: "DetailConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailConfessionCell")

        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0), estimatedHeight: 100)
        
        collectionView.showAnimatedGradientSkeleton()
    }
    
    private func updateScreen() {
        self.collectionView.reloadData()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let maxCount = detailViewModel.getMaxReplyCharacterCount()
        
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
    
    func handleShareAction() {
        Task(priority: .utility) {
            await detailViewModel.createShortlink()
        }
    }
    
    func handleLikeAction() {
        guard let isLiked = detailViewModel.confession?.liked else { return }
        Task {
            if isLiked {
                await detailViewModel.unlikeMessage()
            } else {
                await detailViewModel.likeMessage()
            }
        }
    }
    
    func handleDMButtonAction() {
        let requestBottomSheetVC: RequestBottomSheetViewController = Storyboard.requestBottomSheet.instantiate(.requestBottomSheet)
        
        let viewModel = RequestBottomSheetViewModel(channelMessageId: detailViewModel.getChannelMessageId())
        requestBottomSheetVC.viewModel = viewModel
        
        if let sheet = requestBottomSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { context in
                return context.maximumDetentValue * 0.7
            }
            sheet.detents = [customDetent, .large()]
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        self.present(requestBottomSheetVC, animated: true)
    }
    
    func handleReportConfession() {
        //TODO: -Report Screen Yap
    }
    
    func handleDeleteConfession() {
        showTwoButtonAlert(title: "general.title.warning".localized, message: "confession.message.delete_confirmation".localized, firstButtonTitle: "general.button.yes".localized, firstButtonHandler: { _ in
            self.showLoading()
            Task(priority: .utility) {
                defer {
                    self.hideLoading()
                }
                await self.detailViewModel.deleteConfession()
            }
        }, secondButtonTitle: "general.button.cancel".localized, secondButtonHandler: nil)
    }
    
    func handleReplyButtonAction() {
        replyTextField.becomeFirstResponder()
    }
    
    func handleAdminEditConfession() {
        let adminEditVC: ModerationDetailBottomSheetViewController = Storyboard.moderation.instantiate(.moderationDetailBottomSheet)
        let actionModel = ConfessionActionModel(id: detailViewModel.getChannelMessageId(), isNSFW: detailViewModel.isNSFW())
        
        let viewModel = ModerationDetailBottomSheetViewModel(actionModel: actionModel)
        adminEditVC.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: adminEditVC)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
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

            await detailViewModel.addComment(message: commentText)

            replyTextField.text = ""
            replyTextField.resignFirstResponder()
            replyTextField.layer.borderColor = UIColor.textSecondary.cgColor
        }
    }
}

extension DetailViewController: DetailViewModelOutputProtocol {
    func didCreateShortlink(shortlink: String) {
        let activityViewController = UIActivityViewController(activityItems: [shortlink], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    func didUpdateReplies() {
        collectionView.reloadData()
        
        let repliesCount = detailViewModel.confession?.replies.count ?? 0
        if repliesCount > 0 {
            let indexPath = IndexPath(row: repliesCount - 1, section: 1)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }

    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int) {
        let indexPath = IndexPath(item: 0, section: 0)
        if collectionView.indexPathsForVisibleItems.contains(indexPath),
           let cell = collectionView.cellForItem(at: indexPath) as? DetailHeaderCollectionViewCell {
            cell.updateLikeButton(isLiked: isLiked, animated: false)

            cell.updateLikeCount(newCount: likeCount, animated: true)
        }
    }
    
    func didFetchDetail() {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
            self.updateScreen()
            self.scrollToHighlightedComment()
        }
    }
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
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
    
    func didFailToFetchDetail(with error: Error) {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
            self.handleError(error)
        }
    }
    
    private func scrollToHighlightedComment() {
        guard let highlightId = detailViewModel.getTargetCommentId(),
              let replies = detailViewModel.confession?.replies else { return }
        
        if let index = replies.firstIndex(where: { $0.id == highlightId }) {
            let indexPath = IndexPath(item: index, section: 1)
            
            self.collectionView.layoutIfNeeded()

            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? DetailConfessionCollectionViewCell {
                    cell.flashAnimation()
                }
            }
        }
    }
}

extension DetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == replyTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= detailViewModel.getMaxReplyCharacterCount()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        replyTextField.layer.borderColor = UIColor.textSecondary.cgColor
    }
}
