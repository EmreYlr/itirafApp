//
//  MockNetworkManager.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation
import Alamofire

final class MockNetworkManager: NetworkService {
    var shouldSucceed = true
    var dataToReturn: Decodable?
    var errorToReturn: Error?

    func request<T: Decodable>(
        endpoint: EndpointType,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding
    ) async throws -> T {
        if shouldSucceed, let data = dataToReturn as? T {
            return data
        } else {
            throw errorToReturn ?? URLError(.badServerResponse)
        }
    }
}
