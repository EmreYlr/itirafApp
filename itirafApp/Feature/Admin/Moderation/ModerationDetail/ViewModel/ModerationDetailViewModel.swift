//
//  ModerationDetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

protocol ModerationDetailViewModelProtocol {
    var delegate: ModerationDetailViewModelDelegate? { get set }
    var moderationItem: ModerationData? { get }
    var selectedViolations: [Violation] { get set }
    func postDecision(decision: ModerationDecision, reason: String?,violations: [Violation]? ,notes: String?, isNsfw: Bool?) async
}

protocol ModerationDetailViewModelDelegate: AnyObject {
    func didPostDecisionSuccessfully()
    func didFailPostingDecision(_ error: Error)
}

final class ModerationDetailViewModel {
    weak var delegate: ModerationDetailViewModelDelegate?
    var moderationItem: ModerationData?
    var selectedViolations: [Violation] = []
    private let moderationService: ModerationServiceProtocol
    
    init(moderationItem: ModerationData, moderationService: ModerationServiceProtocol = ModerationService()) {
        self.moderationItem = moderationItem
        self.moderationService = moderationService
    }
    
    init(moderationService: ModerationServiceProtocol = ModerationService()) {
        self.moderationService = moderationService
    }
    
    func postDecision(decision: ModerationDecision, reason: String?, violations: [Violation]?, notes: String?, isNsfw: Bool? = nil) async {
        guard let messageId = moderationItem?.id else { return }
        
        let decisionRequest = ModerationDecisionRequest(
            messageID: messageId,
            decision: decision,
            violations: violations,
            rejectionReason: reason,
            notes: notes,
            isNsfw: isNsfw
        )
        
        do {
            try await moderationService.postDecision(decisionRequest: decisionRequest)
            delegate?.didPostDecisionSuccessfully()
        } catch {
            print("Error posting decision: \(error)")
            delegate?.didFailPostingDecision(error)
        }
    }
}

extension ModerationDetailViewModel: ModerationDetailViewModelProtocol { }
    
