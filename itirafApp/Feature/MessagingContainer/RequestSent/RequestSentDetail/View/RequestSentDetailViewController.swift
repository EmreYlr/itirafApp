//
//  RequestSentDetailViewController.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

import UIKit

final class RequestSentDetailViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var sentConfessionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confessionMessageLabel: UILabel!
    @IBOutlet weak var confessionOwnerUsernameLabel: UILabel!
    @IBOutlet weak var myMessageView: UIView!
    @IBOutlet weak var confessionDateLabel: UILabel!
    @IBOutlet weak var profileIconView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var myMessageLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var profileIconLabel: UILabel!
    
    var viewModel: RequestSentDetailViewModelProtocol
    required init?(coder: NSCoder) {
        self.viewModel = RequestSentDetailViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    private func initUI() {
        guard let sentRequests = viewModel.sentRequests else {
            return
        }
        
        sentConfessionView.layer.cornerRadius = 10
        sentConfessionView.backgroundColor = .systemGray6
        sentConfessionView.layer.borderColor = UIColor.systemGray4.cgColor
        sentConfessionView.layer.borderWidth = 0.5
        
        statusView.layer.cornerRadius = 10
        statusView.backgroundColor = .systemGray6
        
        myMessageView.layer.cornerRadius = 10
        myMessageView.backgroundColor = .systemMint
        myMessageView.layer.borderColor = UIColor.systemGray4.cgColor
        myMessageView.layer.borderWidth = 0.5
        myMessageLabel.textColor = .white
        
        profileIconView.layer.cornerRadius = profileIconView.frame.height / 2
        profileIconView.clipsToBounds = true
        
        buttonView.layer.borderWidth = 0.2
        buttonView.layer.borderColor = UIColor.systemGray4.cgColor
        
        deleteButton.backgroundColor = .systemRed.withAlphaComponent(0.2)
        deleteButton.layer.cornerRadius = 8
        deleteButton.isHidden = sentRequests.status != .pending
        buttonView.isHidden = sentRequests.status != .pending

        confessionMessageLabel.text = sentRequests.confessionMessage
        titleLabel.text = sentRequests.confessionTitle
        confessionDateLabel.text = sentRequests.createdAt.formattedDateTime()
        confessionOwnerUsernameLabel.text = sentRequests.confessionAuthorUsername
        profileIconLabel.text = String(sentRequests.confessionAuthorUsername.prefix(2)).uppercased()
        myMessageLabel.text = sentRequests.initialMessage
        statusLabel.text = sentRequests.status.description.capitalized
        statusImageView.image = sentRequests.status == .pending ? UIImage(systemName: "clock") : UIImage(systemName: "xmark.octagon")
        navigationItem.title = "İstek Detayı"
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        showTwoButtonAlert(title: "Uyarı", message: "Mesajını geri çekmek istediğinizden emin misiniz?", firstButtonTitle: "Evet", firstButtonHandler: {[ weak self] _ in
            Task(priority: .utility) {
                await self?.viewModel.deleteSentRequest()
            }
        }, secondButtonTitle: "İptal", secondButtonHandler: nil)
    }
}

extension RequestSentDetailViewController: RequestSentDetailViewModelDelegate {
    func didDeleteSentRequests() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func didError(error: Error) {
        print("Error deleting sent request: \(error.localizedDescription)")
    }
}
