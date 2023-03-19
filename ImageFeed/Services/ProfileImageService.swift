import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let session = URLSession.shared
    
    private (set) var profileImageLink: String?
    
    private var currentTask: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageLink(_ token: String, for username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread, "This code must be executed on the main thread")
        currentTask?.cancel()
        
        let request = makeUserRequest(with: token, for: username)
        let task = session.decodeTask(from: request) { [weak self] (result: Result<UserBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let link = body.profileImage.small
                self.profileImageLink = link
                completion(.success(link))
                self.currentTask = nil
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["ProfileImageLink": self.profileImageLink as Any]
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func makeUserRequest(with token: String, for username: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    
    private struct UserBody: Decodable {
        let profileImage: ProfileImageBody
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    private struct ProfileImageBody: Decodable {
        let small: String
        
        enum CodingKeys: String, CodingKey {
            case small
        }
    }
}
