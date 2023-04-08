import XCTest
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var isPresentProfileCalled = false
    var isPresentProfileImageURLCalled = false
    var isRemoveUserDataWhenLogoutCalled = false
    
    func presentProfile() -> Profile? {
        isPresentProfileCalled = true
        return nil
    }
    
    func presentProfileImageURL() -> URL? {
        isPresentProfileImageURLCalled = true
        return nil
    }
    
    func removeUserDataWhenLogout() {
        isRemoveUserDataWhenLogoutCalled = true
    }
}

final class ProfileViewTests: XCTestCase {
    
    private let profilePresenterSpy = ProfileViewPresenterSpy()
    private let profileController = ProfileViewController()
    
    func testControllerCallsPresentProfile() {
        // Given
        profileController.presenter = profilePresenterSpy
        
        // When
        profileController.updateProfileData()
        
        // Then
        XCTAssertTrue(profilePresenterSpy.isPresentProfileCalled)
    }
    
    func testControllerCallsPresentProfileImageURL() {
        // Given
        profileController.presenter = profilePresenterSpy
        
        // When
        profileController.updateProfileImage()
        
        // Then
        XCTAssertTrue(profilePresenterSpy.isPresentProfileImageURLCalled)
    }
    
    func testControllerCallsRemoveUserDataWhenLogout() {
        // Given
        profileController.presenter = profilePresenterSpy
        
        // When
        profileController.logoutProfile()
        
        // Then
        XCTAssertTrue(profilePresenterSpy.isRemoveUserDataWhenLogoutCalled)
    }
}
