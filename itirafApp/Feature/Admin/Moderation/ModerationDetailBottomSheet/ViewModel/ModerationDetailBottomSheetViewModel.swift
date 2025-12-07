//
//  ModerationDetailBottomSheetViewModel.swift
//  itirafApp
//
//  Created by Emre on 30.11.2025.
//

protocol ModerationDetailBottomSheetViewModelProtocol {
    var delegate: ModerationDetailBottomSheetViewModelDelegate? { get set }
    var actionModel: ConfessionActionModel { get }
    var selectedViolations: [Violation] { get set }
    func editAdminConfession(decision: ModerationDecision, reason: String?, violations: [Violation]?, isNsfw: Bool?) async
    func editIsNsfwConfession(isNsfw: Bool) async
}

protocol ModerationDetailBottomSheetViewModelDelegate: AnyObject {
    func didEditSuccessfully()
    func didError(_ error: Error)
}

final class ModerationDetailBottomSheetViewModel {
    weak var delegate: ModerationDetailBottomSheetViewModelDelegate?
    let actionModel: ConfessionActionModel
    var selectedViolations: [Violation] = []
    let service: ModerationServiceProtocol
    
    init(actionModel: ConfessionActionModel, service: ModerationServiceProtocol = ModerationService()) {
        self.service = service
        self.actionModel = actionModel
    }
    
    func editAdminConfession(decision: ModerationDecision, reason: String?, violations: [Violation]?, isNsfw: Bool? = nil) async {
        
        let decisionRequest = ModerationDecisionRequest(
            messageID: actionModel.id,
            decision: decision,
            violations: violations,
            rejectionReason: reason,
            notes: nil,
            isNsfw: isNsfw
        )
        
        do {
            try await service.postDecision(decisionRequest: decisionRequest)
            delegate?.didEditSuccessfully()
        } catch {
            delegate?.didError(error)
        }
    }
    
    func editIsNsfwConfession(isNsfw: Bool) async {
        var action = actionModel
        action.isNSFW = isNsfw
        
        do {
            try await service.patchModerationNsfw(action: action)
            delegate?.didEditSuccessfully()
        } catch {
            delegate?.didError(error)
        }
    }
}

extension ModerationDetailBottomSheetViewModel: ModerationDetailBottomSheetViewModelProtocol { }
