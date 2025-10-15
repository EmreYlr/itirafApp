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
    
    var detailViewModel: DetailViewModelProtocol
    
    required init(coder: NSCoder) {
        self.detailViewModel = DetailViewModel()
        super.init(coder: coder)!
    }
    
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
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func initData() {
        detailViewModel.delegate = self
        guard let confession = detailViewModel.confession else { return }
        titleLabel.text = confession.title
        contentLabel.text = confession.message
        likeCountLabel.text = confession.likeCount.description
        commentCountLabel.text = confession.replyCount.description
        self.updateLikeUI()
        
        detailViewModel.fetchMessageData()
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
    
    private func updateLikeUI() {
        guard let confession = detailViewModel.confession else { return }
        let imageName = confession.liked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeCountLabel.text = "\(confession.likeCount)"
    }
    

    
    @IBAction func shareButtonClicked(_ sender: UIButton) { }
    @IBAction func commentButtonClicked(_ sender: UIButton) { }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        detailViewModel.toggleLike()
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) { }
}

extension DetailViewController: DetailViewModelOutputProtocol {
    func didUpdateLikeStatus(isLiked: Bool, likeCount: Int) {
        updateLikeUI()
    }
    
    func didFetchDetail() {
        collectionView.reloadData()
    }
    
    func didFailToFetchDetail(with error: Error) {
        print("Failed to fetch detail: \(error)")
    }
}
