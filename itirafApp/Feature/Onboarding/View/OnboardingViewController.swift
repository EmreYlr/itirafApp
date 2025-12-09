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
    
    var currentPage = 0 {
        didSet {
            updateUI()
        }
    }
    
    required init(coder: NSCoder) {
        self.viewModel = OnboardingViewModel()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        loadCollectionView()
        setupUI()
    }
    
    private func initData() {
        viewModel.delegate = self
    }
    
    private func loadCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = .zero
        }
        
        collectionView.register(UINib(nibName: "OnboardingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onboardingCell")
    }
    
    private func setupUI() {
        backButton.alpha = 0
        backButton.isHidden = true
        backButton.setTitle("common_back".localized, for: .normal)
        backButton.backgroundColor = .textSecondary.withAlphaComponent(0.2)
        backButton.layer.cornerRadius = 8
        nextButton.backgroundColor = .brandPrimary.withAlphaComponent(0.2)
        nextButton.layer.cornerRadius = 8
        
        pageController.numberOfPages = viewModel.numberOfSlides
        updateUI()
    }
    
    private func updateUI() {
        pageController.currentPage = currentPage
        let isFirstPage = currentPage == 0
        if isFirstPage {
            if !backButton.isHidden {
                UIView.animate(withDuration: 0.3, animations: {
                    self.backButton.alpha = 0
                }) { _ in
                    self.backButton.isHidden = true
                }
            }
        } else {
            if backButton.isHidden {
                backButton.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.backButton.alpha = 1
                }
            }
        }
        
        let targetTitle = (currentPage == viewModel.numberOfSlides - 1) ? "common_start".localized : "common_next".localized
        if nextButton.title(for: .normal) != targetTitle {
            
            UIView.transition(with: nextButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                
                self.nextButton.setTitle(targetTitle, for: .normal)
                self.nextButton.backgroundColor = (self.currentPage == 2) ? .brandSecondary : .brandPrimary
            }, completion: nil)
        }
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if currentPage > 0 {
            currentPage -= 1
            scrollToIndex(index: currentPage)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let nextIndex = viewModel.handleNextAction(currentIndex: currentPage) {
            currentPage = nextIndex
            scrollToIndex(index: currentPage)
        }
    }
    
    private func scrollToIndex(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension OnboardingViewController: OnboardingViewModelDelegate {
    func didCompleteOnboarding() {
        print("Onboarding Bitti! Ana sayfaya geçiliyor...")
    }
}
