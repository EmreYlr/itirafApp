//
//  NetworkService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire

protocol NetworkService {
    func request<T: Decodable>(
        endpoint: EndpointType,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding
    ) async throws -> T
}
