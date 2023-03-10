import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let session = URLSession.shared
    
    private (set) var profileImageLink: String?
    
    private var lastTask: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageLink(_ token: String, for username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        let request = makeUserRequest(token, for: username)
        let task = session.decodeTask(from: request) { [weak self] (result: Result<UserBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let link = body.profileImage.small
                self.profileImageLink = link
                completion(.success(link))
                self.lastTask = nil
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": self.profileImageLink as Any]
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        lastTask = task
        task.resume()
    }
    
    private func makeUserRequest(_ token: String, for username: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    
    private struct UserBody: Decodable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    private struct ProfileImage: Decodable {
        let small: String
        
        enum CodingKeys: String, CodingKey {
            case small
        }
    }
}
