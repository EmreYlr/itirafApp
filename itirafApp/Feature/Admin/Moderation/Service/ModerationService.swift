//
//  ModerationService.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//
import Alamofire

protocol ModerationServiceProtocol {
    func getModerationData(page: Int, limit: Int) async throws -> ModerationModel
    func postDecision(decisionRequest: ModerationDecisionRequest) async throws
}

final class ModerationService: ModerationServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getModerationData(page: Int, limit: Int) async throws -> ModerationModel {
        
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Admin.getModerationMessages,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func postDecision(decisionRequest: ModerationDecisionRequest) async throws {
        let messageID = decisionRequest.messageID
        let parameters: [String: Any]
        
        switch decisionRequest.decision {
        case .approve:
            parameters = [
                "decision": decisionRequest.decision.rawValue,
                "notes": decisionRequest.notes ?? "",
                "isNsfw": decisionRequest.isNsfw ?? false
            ]
        case .reject:
            parameters = [
                "decision": decisionRequest.decision.rawValue,
                "violations": (decisionRequest.violations ?? []).map { $0.rawValue },
                "rejectionReason": decisionRequest.rejectionReason ?? "",
                "notes": decisionRequest.notes ?? ""
            ]
        }

        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Admin.postModerationMessage(messageID: messageID),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
