//
//  ViolationsViewController.swift
//  itirafApp
//
//  Created by Emre on 8.11.2025.
//

import UIKit

protocol ViolationsViewControllerDelegate: AnyObject {
    func didSelectViolations(_ violations: [Violation])
}

final class ViolationsViewController: UIViewController {
    //MARK:- Properties
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: ViolationsViewControllerDelegate?
    private let allViolations = Violation.selectableCases
    var selectedViolations: [Violation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ViolationCell")
        
        configureNavigation()
    }
    
    private func configureNavigation() {
        self.title = "violations.title".localized
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "general.button.save".localized,
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        self.navigationItem.rightBarButtonItem?.tintColor = .brandSecondary
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "general.button.clear".localized,
            style: .plain,
            target: self,
            action: #selector(clearButtonTapped)
        )
        
        self.navigationItem.leftBarButtonItem?.tintColor = .statusError
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectViolations(selectedViolations)
        dismiss(animated: true)
    }
    
    @objc private func clearButtonTapped() {
        selectedViolations.removeAll()
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        }
    }
}

extension ViolationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allViolations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell", for: indexPath)
        let violation = allViolations[indexPath.row]
        
        cell.textLabel?.text = violation.description
        cell.selectionStyle = .none

        cell.tintColor = .brandSecondary

        if selectedViolations.contains(violation) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let violation = allViolations[indexPath.row]
        if !selectedViolations.contains(violation) {
            selectedViolations.append(violation)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        let violation = allViolations[indexPath.row]
        selectedViolations.removeAll { $0 == violation }
    }
}
