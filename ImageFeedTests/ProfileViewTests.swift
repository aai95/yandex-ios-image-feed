import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var controller: ProfileViewControllerProtocol?
    var isPresentProfileCalled = false
    var isPresentProfileImageCalled = false
    
    func presentProfile() {
        isPresentProfileCalled = true
    }
    
    func presentProfileImage() {
        isPresentProfileImageCalled = true
    }
    
    func removeUserDataBeforeLogout() {}
}

final class ProfileViewTests: XCTestCase {
    
    func testControllerCallsPresentFunctions() {
        // Given
        let profilePresenterSpy = ProfilePresenterSpy()
        let profileController = ProfileViewController()
        
        profileController.configure(presenter: profilePresenterSpy)
        
        // When
        _ = profileController.view
        
        // Then
        XCTAssertTrue(profilePresenterSpy.isPresentProfileCalled)
        XCTAssertTrue(profilePresenterSpy.isPresentProfileImageCalled)
    }
}
