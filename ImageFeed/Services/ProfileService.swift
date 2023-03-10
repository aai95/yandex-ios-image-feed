import Foundation

final class ProfileService {
    
    private let urlSession = URLSession.shared
    
    private(set) var profile: Profile?
    
    static let shared = ProfileService()
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        var request = URLRequest.makeHTTPRequest(path: "/me", method: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.decodeTask(from: request) { [weak self] (result: Result<ProfileBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let profile = self.convertProfile(body: body)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func convertProfile(body: ProfileBody) -> Profile {
        return Profile(
            userName: body.userName,
            name: "\(body.firstName) \(body.lastName ?? "")",
            loginName: "@\(body.userName)",
            bio: body.bio ?? ""
        )
    }
}

extension ProfileService {
    
    struct Profile {
        let userName: String
        let name: String
        let loginName: String
        let bio: String
    }
    
    private struct ProfileBody: Decodable {
        let userName: String
        let firstName: String
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case userName = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
}
