//
//  ReportService.swift
//  itirafApp
//
//  Created by Emre on 11.12.2025.
//
import Alamofire

protocol ReportServiceProtocol {
    func reportConfession(messageId: Int, reason: String) async throws
    func reportRoom(roomId: String, reason: String) async throws
}

final class ReportService: ReportServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func reportConfession(messageId: Int, reason: String) async throws {
        let parameters: [String: Any] = [
            "reason": reason
        ]
        
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Report.reportMessages(messageId: messageId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func reportRoom(roomId: String, reason: String) async throws {
        let parameters: [String: Any] = [
            "reason": reason
        ]
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Report.reportDM(roomId: roomId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
