//
//  ModerationViewModel.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

import Foundation // Foundation'ı ekledim

protocol ModerationViewModelProtocol {
    var delegate: ModerationViewModelDelegate? { get set }
    var moderationItems: [ModerationData] { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchModerationData(reset: Bool) async
}

protocol ModerationViewModelDelegate: AnyObject {
    func didUpdateModerationItems(with data: [ModerationData])
    func didFailWithError(_ error: Error)
}

final class ModerationViewModel {
    weak var delegate: ModerationViewModelDelegate?
    private let moderationService: ModerationServiceProtocol
    private(set) var moderationModel: ModerationModel?
    
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    var moderationItems: [ModerationData] {
        moderationModel?.data ?? []
    }
    
    init(moderationService: ModerationServiceProtocol = ModerationService()) {
        self.moderationService = moderationService
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
            
            delegate?.didUpdateModerationItems(with: moderationItems)
            
        } catch {
            delegate?.didFailWithError(error)
        }
    }
}

extension ModerationViewModel: ModerationViewModelProtocol { }
