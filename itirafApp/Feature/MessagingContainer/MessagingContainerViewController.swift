//
//  MessagingContainerViewController.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import UIKit

final class MessagingContainerViewController: UIViewController {
    //MARK: -Properties
    var initialIndex: Int = 0
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["messaging.segment.messages".localized, "messaging.segment.requests".localized])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        
        sc.backgroundColor = .clear
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        sc.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.systemMint], for: .selected)
        
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private lazy var bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectionIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint!
    private var indicatorWidthConstraint: NSLayoutConstraint!
    
    
    private lazy var pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        pvc.dataSource = self
        pvc.delegate = self
        return pvc
    }()
    
    private lazy var directMessagesVC: DirectMessageViewController = {
        return Storyboard.directMessage.instantiate(.directMessage)
    }()
    
    lazy var requestsVC: RequestMessageViewController = {
        return Storyboard.requestMessage.instantiate(.requestMessage)
    }()
    
    private lazy var pages: [UIViewController] = [directMessagesVC, requestsVC]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func initData() {
        self.navigationItem.title = "messaging.title".localized
        setupUI()
        segmentedControl.selectedSegmentIndex = initialIndex
        
        setInitialViewController()
        DispatchQueue.main.async {
            self.updateSelectionIndicator(to: self.initialIndex)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentedControl)
        
        view.addSubview(bottomBorderView)
        view.addSubview(selectionIndicatorView)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        let image = UIImage(systemName: "person.crop.circle.badge.questionmark")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(requestsSentButtonTapped)
        )
        
        indicatorWidthConstraint = selectionIndicatorView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 0.5)
        indicatorLeadingConstraint = selectionIndicatorView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            bottomBorderView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1),
            
            selectionIndicatorView.bottomAnchor.constraint(equalTo: bottomBorderView.bottomAnchor),
            selectionIndicatorView.heightAnchor.constraint(equalToConstant: 2),
            indicatorWidthConstraint,
            indicatorLeadingConstraint,
            
            pageViewController.view.topAnchor.constraint(equalTo: bottomBorderView.bottomAnchor, constant: 1),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func updateSelectionIndicator(to index: Int) {
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        
        let newLeadingConstant = segmentWidth * CGFloat(index)
        
        indicatorLeadingConstraint.constant = newLeadingConstant
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func requestsSentButtonTapped() {
        let requestsSentVC: RequestSentViewController = Storyboard.requestSent.instantiate(.requestSent)
        navigationController?.pushViewController(requestsSentVC, animated: true)
        
    }
    
    private func setInitialViewController() {
        let initialVC = pages[initialIndex]
        pageViewController.setViewControllers(
            [initialVC],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        guard let currentIndex = pages.firstIndex(of: currentVC) else { return }
        
        if selectedIndex != currentIndex {
            let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
            let vc = pages[selectedIndex]
            updateSelectionIndicator(to: selectedIndex)
            pageViewController.setViewControllers([vc], direction: direction, animated: true)
        }
    }
}

extension MessagingContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == 0 {
            return nil
        }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == (pages.count - 1) {
            return nil
        }
        
        return pages[index + 1]
    }
}
extension MessagingContainerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = pageViewController.viewControllers?.first,
               let index = pages.firstIndex(of: currentVC) {
                segmentedControl.selectedSegmentIndex = index
            }
        } else {
            guard let previousVC = previousViewControllers.first,
                  let index = pages.firstIndex(of: previousVC) else {
                return
            }
            segmentedControl.selectedSegmentIndex = index
            updateSelectionIndicator(to: index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let pendingVC = pendingViewControllers.first,
              let index = pages.firstIndex(of: pendingVC) else {
            return
        }
        
        segmentedControl.selectedSegmentIndex = index
        updateSelectionIndicator(to: index)
        
    }
}
