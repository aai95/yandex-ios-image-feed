import Foundation

protocol ProfileViewPresenterProtocol {
    func presentProfile() -> Profile?
    func presentProfileImageURL() -> URL?
    func removeUserDataWhenLogout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func presentProfile() -> Profile? {
        return profileService.profile
    }
    
    func presentProfileImageURL() -> URL? {
        guard let link = profileImageService.profileImageLink else {
            return nil
        }
        return URL(string: link)
    }
    
    func removeUserDataWhenLogout() {
        tokenStorage.removeAuthToken()
        WebViewViewController.removeCookiesAndWebsiteData()
    }
}
