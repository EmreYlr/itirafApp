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
        let deleteImage = UIImage(systemName: "trash.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: deleteImage , style: .done, target: self, action: #selector(deleteButtonTapped))
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "MyConfessionHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myconfesionHeaderCell")
        
        collectionView.register(UINib(nibName: "DetailConfessionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "detailConfessionCell")
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.frame.width
            flowLayout.estimatedItemSize = CGSize(width: width, height: 100)
            flowLayout.scrollDirection = .vertical
        }
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
