//
//  MockUserService.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import Foundation

final class MockUserService: UserServiceProtocol {
    
    var shouldSucceed = true
    
    var userToReturn: User?
    
    var errorToReturn: Error?

    func fetchCurrentUser() async throws -> User {
        if shouldSucceed {
            guard let user = userToReturn else {
                fatalError("MockUserService başarılı olarak ayarlandı ancak 'userToReturn' değeri sağlanmadı.")
            }
            return user
        } else {
            throw errorToReturn ?? NSError(domain: "MockUserServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock hata oluştu"])
        }
    }
}
