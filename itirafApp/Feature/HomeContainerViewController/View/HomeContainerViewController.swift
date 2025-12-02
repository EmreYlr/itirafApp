//
//  HomeContainerViewController.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import UIKit

final class HomeContainerViewController: UIViewController {
    //MARK: - Properties
    private lazy var newPostButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.backgroundColor = .systemMint
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "plus.bubble.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white

        btn.layer.cornerRadius = 25

        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 4
        
        btn.addTarget(self, action: #selector(newPostButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["home.segment.flow".localized, "home.segment.following".localized])
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
    
    private lazy var flowVC: FlowViewController = {
        return Storyboard.main.instantiate(.flow)
    }()
    
    private lazy var homeVC: HomeViewController = {
        return Storyboard.main.instantiate(.home)
    }()
    
    private lazy var pages: [UIViewController] = [flowVC, homeVC]
    private var notificationButton: UIBarButtonItem!
    var viewModel: HomeContainerViewModelProtocol
    
    required init?(coder: NSCoder) {
        self.viewModel = HomeContainerViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupUI()
        setInitialViewController()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.tabBarController?.delegate = self
        
        Task {
            await viewModel.getNotificationStatus()
        }
    }
    
    private func configureNavigationBar() {
        let messageButton = UIBarButtonItem(
            image: UIImage(systemName: "message"),
            style: .plain,
            target: self,
            action: #selector(messageButtonTapped)
        )
        messageButton.tintColor = .systemMint
        
        notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(notificationButtonTapped)
        )
        notificationButton.tintColor = .systemMint
        
        navigationItem.rightBarButtonItems = [messageButton, notificationButton]
    }
    
    private func initData() {
        viewModel.delegate = self
        self.title = "home.title".localized
    }
    
    private func showNotificationBadge(show: Bool) {
        DispatchQueue.main.async {
            if show {
                let config = UIImage.SymbolConfiguration(paletteColors: [.systemMint, .systemMint])
                let badgeImage = UIImage(systemName: "bell.badge.fill", withConfiguration: config)
                
                self.notificationButton.image = badgeImage
            } else {
                self.notificationButton.image = UIImage(systemName: "bell")
            }
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
        
        view.addSubview(newPostButton)
        view.bringSubviewToFront(newPostButton)
        
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
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            newPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            newPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            newPostButton.widthAnchor.constraint(equalToConstant: 50),
            newPostButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            newPostButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func setInitialViewController() {
        pageViewController.setViewControllers(
            [flowVC],
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
    
    @objc private func notificationButtonTapped() {
        let notificationVC: NotificationViewController = Storyboard.notification.instantiate(.notification)
        navigationController?.pushViewController(notificationVC, animated: true)
    }

    @objc private func messageButtonTapped() {
        let messagingContainerVC = MessagingContainerViewController()
        navigationController?.pushViewController(messagingContainerVC, animated: true)
    }
    
    @objc private func newPostButtonTapped() {
        let postConfessionVC: PostConfessionViewController = Storyboard.post.instantiate(.postConfession)
        navigationController?.pushViewController(postConfessionVC, animated: true)
        
    }
}
extension HomeContainerViewController: HomeContainerViewModelDelegate {
    func didUpdateNotificationStatus(_ status: NotificationStatus) {
        let show =  status.hasUnread
        showNotificationBadge(show: show)
    }
    
    func didFailToUpdateNotificationStatus() {
        showNotificationBadge(show: false)
        print("Failed to update notification status")
    }
}


extension HomeContainerViewController: UIPageViewControllerDataSource {
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

extension HomeContainerViewController: UIPageViewControllerDelegate {
    
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

extension HomeContainerViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController {
            if let nav = viewController as? UINavigationController, nav.topViewController === self {
                
                if segmentedControl.selectedSegmentIndex == 0 {
                    flowVC.scrollToTop()
                } else {
                    homeVC.scrollToTop()
                }
            }
        }
        return true
    }
}
