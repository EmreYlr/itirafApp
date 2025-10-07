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
        
    }
    
    private func initData() {
        channelViewModel.delegate = self
        channelViewModel.fetchChannel()
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension ChannelViewController: ChannelViewModelOutputProtocol {
    func didUpdateChannel() {
        tableView.reloadData()
    }
    
    func didFailWithError(_ error: any Error) {
        print(error.localizedDescription)
    }
}

