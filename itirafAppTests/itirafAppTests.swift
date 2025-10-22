//
//  itirafAppTests.swift
//  itirafAppTests
//
//  Created by Emre on 24.09.2025.
//

import XCTest
@testable import itirafApp

final class LoginServiceTests: XCTestCase {

    var mockNetworkManager: MockNetworkManager!
    var mockUserService: MockUserService!
    var loginService: LoginService!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockUserService = MockUserService()
        loginService = LoginService(networkService: mockNetworkManager, userService: mockUserService)
        
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
    }

    override func tearDown() {
        mockNetworkManager = nil
        mockUserService = nil
        loginService = nil
        super.tearDown()
    }

    func testLoginUser_Success_ShouldSaveTokenAndUser() async throws {
        /// GIVEN
        let expectedTokens = RefreshTokenResponse(accessToken: "fake_access_token", refreshToken: "fake_refresh_token")
        mockNetworkManager.shouldSucceed = true
        mockNetworkManager.dataToReturn = expectedTokens
        
        let expectedUser = User(id: "user123", username: "testuser", email: "test@test.com", isAnonymous: false)
        mockUserService.shouldSucceed = true
        mockUserService.userToReturn = expectedUser

        /// WHEN
        try await loginService.loginUser(email: "test@test.com", password: "password")
        
        /// THEN
        let savedToken = AuthManager.shared.getAccessToken()
        
        XCTAssertEqual(savedToken, expectedTokens.accessToken, "Giriş sonrası access token doğru şekilde kaydedilmeli.")
    }
}
