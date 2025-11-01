//
//  MessagingContainerViewController.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import UIKit

final class MessagingContainerViewController: UIViewController {
    //MARK: -Properties
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mesajlar", "İstekler"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        sc.selectedSegmentTintColor = .systemMint
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private lazy var separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemGray5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    
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
    
    private lazy var requestsVC: RequestMessageViewController = {
        return Storyboard.requestMessage.instantiate(.requestMessage)
    }()
    
    private lazy var pages: [UIViewController] = [directMessagesVC, requestsVC]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mesajlaşma"
        setupUI()
        setInitialViewController()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentedControl)
        view.addSubview(separatorView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 15),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            pageViewController.view.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func setInitialViewController() {
        pageViewController.setViewControllers(
            [directMessagesVC],
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
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let pendingVC = pendingViewControllers.first,
              let index = pages.firstIndex(of: pendingVC) else {
            return
        }
        
        segmentedControl.selectedSegmentIndex = index
    }
}
