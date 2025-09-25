//
//  MockNetworkManager.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation
import Alamofire

final class MockNetworkManager {
    var shouldSucceed = true
    var dataToReturn: Decodable?
    var errorToReturn: Error?

    func request<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void) {
        if shouldSucceed, let data = dataToReturn as? T {
            completion(.success(data))
        } else {
            completion(.failure(errorToReturn ?? URLError(.badServerResponse)))
        }
    }
}

extension MockNetworkManager: NetworkService { }
