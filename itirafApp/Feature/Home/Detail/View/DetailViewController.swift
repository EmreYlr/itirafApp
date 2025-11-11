//
//  DetailViewController.swift
//  itirafApp
//
//  Created by Emre on 30.09.2025.
//

import UIKit

final class DetailViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    
    var detailViewModel: DetailViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailViewController")
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
        contentView.layer.cornerRadius = 10
    }
    
    private func initData() {
        detailViewModel.delegate = self
        let dmImage = UIImage(systemName: "bubble.left.and.bubble.right")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: dmImage , style: .done, target: self, action: #selector(dmButtonTapped))
        
        Task {
            await detailViewModel.fetchMessageData()
        }
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
    
    private func updateLikeUI(isLike: Bool, likeCount: Int) {
        let imageName = isLike ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeCountLabel.text = "\(likeCount)"
    }
    
    private func updateScreen() {
        guard let confession = detailViewModel.confession else { return }
        titleLabel.text = confession.title
        contentLabel.text = confession.message
        likeCountLabel.text = confession.likeCount.description
        commentCountLabel.text = confession.replyCount.description
        self.updateLikeUI(isLike: confession.liked, likeCount: confession.likeCount)
    }
    
    @objc func dmButtonTapped() {
        let requestBottomSheetVC: RequestBottomSheetViewController = Storyboard.requestBottomSheet.instantiate(.requestBottomSheet)
        
        let viewModel = RequestBottomSheetViewModel(channelMessageId: detailViewModel.getChannelMessageId())
        requestBottomSheetVC.viewModel = viewModel
        
        if let sheet = requestBottomSheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { context in
                return context.maximumDetentValue * 0.65
            }
            sheet.detents = [customDetent, .large()]
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        self.present(requestBottomSheetVC, animated: true)
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton) {
        Task(priority: .utility) {
            await detailViewModel.createShortlink()
        }
    }
    
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        CrashlyticsManager.shared.logMessage("Comment button clicked - Feature not implemented yet.")
        fatalError("Comment feature is not implemented yet.")
    }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        guard let isLiked = detailViewModel.confession?.liked else { return }
        sender.isEnabled = false
        
        Task {
            defer {
                sender.isEnabled = true
            }
            if isLiked {
                await detailViewModel.unlikeMessage()
            } else {
                await detailViewModel.likeMessage()
            }
        }
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
        }
    }
}

extension DetailViewController: DetailViewModelOutputProtocol {
    func didCreateShortlink(shortlink: ShortlinkResponse) {
        let textToShare = shortlink.url
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func didFailToCreateShortlink(with error: any Error) {
        print("Failed to create shortlink: \(error)")
    }
    
    func didUpdateReplies() {
        collectionView.reloadData()
    }
    
    func didFailToAddComment(with error: any Error) {
        print("Failed to add comment: \(error)")
    }
    
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int) {
        updateLikeUI(isLike: isLiked, likeCount: likeCount)
    }
    
    func didFetchDetail() {
        print("Detail Fetched")
        DispatchQueue.main.async {
            self.updateScreen()
            self.collectionView.reloadData()
        }
    }
    
    func didFailToLikeMessage(with error: Error) {
        print("Failed to like message: \(error)")
    }
    
    func didFailToFetchDetail(with error: Error) {
        print("Failed to fetch detail: \(error)")
    }
}
