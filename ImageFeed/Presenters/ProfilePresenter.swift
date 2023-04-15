import Foundation

protocol ProfilePresenterProtocol {
    var controller: ProfileViewControllerProtocol? { get set }
    
    func presentProfile()
    func presentProfileImage()
    func removeUserDataBeforeLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    weak var controller: ProfileViewControllerProtocol?
    
    func presentProfile() {
        guard let profile = profileService.profile else {
            return
        }
        controller?.updateProfile(model: profile)
    }
    
    func presentProfileImage() {
        guard let link = profileImageService.profileImageLink,
              let url = URL(string: link)
        else {
            return
        }
        controller?.updateProfileImage(url: url)
    }
    
    func removeUserDataBeforeLogout() {
        tokenStorage.removeAuthToken()
        WebViewViewController.removeCookiesAndWebsiteData()
        
        controller?.logoutProfile()
    }
}
