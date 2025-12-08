//
//  MyConfessionsViewModel.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

protocol MyConfessionsViewModelProtocol {
    var delegate: MyConfessionsViewModelDelegate? { get set }
    var myConfession: MyConfession? { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchMyConfessions(reset: Bool) async
    func isUserAdmin() -> Bool
}

protocol MyConfessionsViewModelDelegate: AnyObject {
    func didUpdateConfessions(with data: [MyConfessionData])
    func didEmptyConfessions()
    func didError(_ error: Error)
}

final class MyConfessionsViewModel {
    weak var delegate: MyConfessionsViewModelDelegate?
    private(set) var myConfession: MyConfession?
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    private let myConfessionsService: MyConfessionsServiceProtocol
    
    init(myConfessionsService: MyConfessionsServiceProtocol = MyConfessionsService()) {
        self.myConfessionsService = myConfessionsService
    }
    
    func fetchMyConfessions(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            myConfession = nil
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newMyConfessions = try await myConfessionsService.fetchMyConfessions(page: currentPage, limit: 10)
            
            if self.myConfession == nil {
                self.myConfession = newMyConfessions
            } else {
                self.myConfession?.data.append(contentsOf: newMyConfessions.data)
            }
            
            hasMoreData = currentPage < newMyConfessions.totalPages
            if hasMoreData { currentPage += 1 }
            
            let currentData = myConfession?.data ?? []
            if currentData.isEmpty {
                delegate?.didEmptyConfessions()
            } else {
                delegate?.didUpdateConfessions(with: currentData)
            }
            
            
            
        } catch {
            delegate?.didError(error)
        }
    }
    
    func isUserAdmin() -> Bool {
        return UserManager.shared.hasRole(.admin)
    }
    
}

extension MyConfessionsViewModel: MyConfessionsViewModelProtocol { }
