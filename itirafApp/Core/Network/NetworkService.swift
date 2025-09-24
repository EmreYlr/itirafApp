//
//  NetworkService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire

protocol NetworkService {
    func request<T: Decodable>(path: String, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void)
}
