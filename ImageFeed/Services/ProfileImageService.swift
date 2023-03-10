import Foundation

final class ProfileImageService {
    
    private let urlSession = URLSession.shared
    
    private (set) var profileImageURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    
    private init() {}
    
    func fetchProfileImageURL(_ token: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", method: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.decodeTask(from: request) { [weak self] (result: Result<UserBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let url = body.profileImage.small
                self.profileImageURL = url
                completion(.success(url))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": self.profileImageURL as Any]
                )
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension ProfileImageService {
    
    private struct ProfileImage: Decodable {
        let small: String
        
        enum CodingKeys: String, CodingKey {
            case small
        }
    }
    
    private struct UserBody: Decodable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
}
