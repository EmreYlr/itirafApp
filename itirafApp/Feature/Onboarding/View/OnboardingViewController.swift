//
//  OnboardingViewController.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var viewModel: OnboardingViewModelProtocol
    required init(coder: NSCoder) {
        self.viewModel = OnboardingViewModel()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        loadCollectionView()
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "OnboardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onboardingCell")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
    }
    @IBAction func nextButtonTapped(_ sender: UIButton) {
    }
}

extension OnboardingViewController: OnboardingViewModelDelegate {
    func didCompleteOnboarding() {
        
    }
    
    func didError(_ error: any Error) {
        
    }
}
