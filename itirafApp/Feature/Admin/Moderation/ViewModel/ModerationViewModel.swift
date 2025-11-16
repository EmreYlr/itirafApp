//
//  ModerationViewModel.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import Foundation

protocol ModerationViewModelProtocol {
    var delegate: ModerationViewModelDelegate? { get set }
    var moderationItems: [ModerationData] { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    var filteredItems: [ModerationData] { get }
    func fetchModerationData(reset: Bool) async
    func setFilter(_ filter: ModerationFilterType)
}

protocol ModerationViewModelDelegate: AnyObject {
    func didUpdateModerationItems()
    func didFailWithError(_ error: Error)
}

final class ModerationViewModel {
    weak var delegate: ModerationViewModelDelegate?
    private let moderationService: ModerationServiceProtocol
    private(set) var moderationModel: ModerationModel?
    
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    private var currentFilter: ModerationFilterType = .all
    
    var moderationItems: [ModerationData] {
        moderationModel?.data ?? []
    }
    
    var filteredItems: [ModerationData] {
        switch currentFilter {
        case .all:
            return moderationItems
        case .pending:
            return moderationItems.filter {
                $0.moderationStatus == .pending || $0.moderationStatus == .needsHumanReview
            }
        case .rejected:
            return moderationItems.filter { $0.moderationStatus == .aiRejected }
        }
    }
    
    init(moderationService: ModerationServiceProtocol = ModerationService()) {
        self.moderationService = moderationService
    }
    
    func setFilter(_ filter: ModerationFilterType) {
        currentFilter = filter
        delegate?.didUpdateModerationItems()
    }
    
    func fetchModerationData(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            moderationModel = nil
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newModel = try await moderationService.getModerationData(page: currentPage, limit: 10)
            
            if self.moderationModel == nil {
                self.moderationModel = newModel
            } else {
                self.moderationModel?.data.append(contentsOf: newModel.data)
                self.moderationModel?.page = newModel.page
                self.moderationModel?.totalPages = newModel.totalPages
            }
            
            if let totalPages = moderationModel?.totalPages {
                hasMoreData = currentPage < totalPages
            } else {
                hasMoreData = false
            }
            
            if hasMoreData { currentPage += 1 }
            
            delegate?.didUpdateModerationItems()
            
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
}
extension ModerationViewModel: ModerationViewModelProtocol { }

enum ModerationFilterType {
    case all
    case pending
    case rejected
}
