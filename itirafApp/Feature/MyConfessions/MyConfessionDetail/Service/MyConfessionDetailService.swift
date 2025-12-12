//
//  MyConfessionDetailService.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import Alamofire

protocol MyConfessionDetailServiceProtocol {
    func deleteConfession(myConfession: MyConfessionData) async throws
    func repliesMessage(message: String, messageId: Int) async throws
    func deleteReply(replyId: Int) async throws
    func blockUser(userId: String) async throws
    func createShortlink(messageId: Int) async throws -> ShortlinkResponse
}

final class MyConfessionDetailService: MyConfessionDetailServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func deleteConfession(myConfession: MyConfessionData) async throws {
        let messageId = myConfession.id
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.deleteUserMessage(messageId: messageId),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
    
    func repliesMessage(message: String, messageId: Int) async throws {
        let parameters: [String: Any] = ["message": message]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.repliesMessage(messageId: messageId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func deleteReply(replyId: Int) async throws {
        let replyId = replyId
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.deleteReply(replyId: replyId),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
    
    func blockUser(userId: String) async throws {
        let parameters: [String: Any] = [
            "userId": userId
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.blockUser,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func createShortlink(messageId: Int) async throws -> ShortlinkResponse {
        let parameters: [String: Any] = [
            "messageId": messageId
        ]
        
         return try await networkService.request(
            endpoint: Endpoint.Shortlink.createShortlinks,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
