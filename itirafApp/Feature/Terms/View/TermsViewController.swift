//
//  TermsViewController.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit
import SafariServices

final class TermsViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var showAppButton: UIButton!
    @IBOutlet weak var acceptSwitch: UISwitch!
    @IBOutlet weak var acceptLabel: UILabel!
    @IBOutlet weak var detailTermsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var termsTitleLabel: UILabel!
    
    var didFinishTerms: (() -> Void)?
    
    var viewModel: TermsViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = TermsViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupUI()
        loadCollectionView()
    }
    
    private func setupUI() {
        termsTitleLabel.text = "terms_title".localized
        acceptLabel.text = "terms_accept_label".localized
        detailTermsButton.setTitle("terms_detail_button".localized, for: .normal)
        showAppButton.setTitle("terms_show_app_button".localized, for: .normal)
        
        detailTermsButton.backgroundColor = .backgroundCard
        detailTermsButton.layer.cornerRadius = 8
        
        showAppButton.backgroundColor = .brandPrimary
        showAppButton.layer.cornerRadius = 8
        showAppButton.setTitleColor(.white, for: .normal)
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = .createFullWidthDynamicLayout(spacing: 10, contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), estimatedHeight: 70)
        
        collectionView.register(UINib(nibName: "TermsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "termsCell")
    }
    
    private func initData() {
        acceptSwitch.isOn = false
        showAppButton.isEnabled = false
        showAppButton.alpha = 0.5
    }

    @IBAction func detailTermsButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: viewModel.getTermsURL()) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .brandPrimary
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }
    
    @IBAction func acceptChangedSwitch(_ sender: UISwitch) {
        showAppButton.isEnabled = sender.isOn
        showAppButton.alpha = sender.isOn ? 1.0 : 0.5
    }
    
    @IBAction func showAppButtonTapped(_ sender: UIButton) {
        if acceptSwitch.isOn {
            UserDefaults.standard.set(true, forKey: .hasAcceptedTerms)
            didFinishTerms?()
        }
    }
}

