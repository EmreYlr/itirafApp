//
//  ChannelViewController.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import UIKit

final class ChannelViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var loadingFooter: UIActivityIndicatorView!
    var channelViewModel: ChannelViewModelProtocol
    
    required init(coder: NSCoder) {
        self.channelViewModel = ChannelViewModel()
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChannelViewController")
        initTableView()
        initData()
        initSearchBar()
        
    }
    
    private func initData() {
        channelViewModel.delegate = self
        channelViewModel.fetchChannel(reset: true)
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshChannels), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadingFooter = UIActivityIndicatorView(style: .medium)
        loadingFooter.hidesWhenStopped = true
        loadingFooter.color = .gray
    }
    
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Üniversite ara..."
        searchBar.showsCancelButton = true
    }
    
    @objc private func refreshChannels() {
        channelViewModel.fetchChannel(reset: true)
    }

}

extension ChannelViewController: ChannelViewModelOutputProtocol {
    func didStartLoading() {
        DispatchQueue.main.async {
            self.loadingFooter.startAnimating()
            self.loadingFooter.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 44)
            self.tableView.tableFooterView = self.loadingFooter
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async {
            self.loadingFooter.stopAnimating()
            self.tableView.tableFooterView = UIView()
        }
    }

    func didUpdateChannel() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)
    }
}

