//
//  itirafAppTests.swift
//  itirafAppTests
//
//  Created by Emre on 24.09.2025.
//

import XCTest
@testable import itirafApp

final class itirafAppTests: XCTestCase {
    
    func testLoginUser_Success() {
        /// GIVEN
        let mockNetworkService = MockNetworkManager()
        let expectedResponse = RefreshTokenResponse(accessToken: "fake_access_token", refreshToken: "fake_refresh_token")
        mockNetworkService.shouldSucceed = true
        mockNetworkService.dataToReturn = expectedResponse

        let loginService = LoginService(networkService: mockNetworkService)
        let expectation = self.expectation(description: "Login should succeed")
        
        let email = "test@gmail.com"
        let password = "12345"
        
        /// WHEN
        loginService.loginUser(email: email, password: password) { result in
            /// THEN
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, expectedResponse.accessToken)
                XCTAssertEqual(response.refreshToken, expectedResponse.refreshToken)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Login should have succeeded, but failed with error: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
        
        
        
    }
    
}
