import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    
    private let session = URLSession.shared
    
    private(set) var profile: Profile?
    
    private var currentTask: URLSessionTask?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread, "This code must be executed on the main thread")
        currentTask?.cancel()
        
        let request = makeProfileRequest(with: token)
        let task = session.decodeTask(from: request) { [weak self] (result: Result<ProfileBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let profile = self.convertProfile(from: body)
                self.profile = profile
                completion(.success(profile))
                self.currentTask = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func makeProfileRequest(with token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/me")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func convertProfile(from body: ProfileBody) -> Profile {
        return Profile(
            username: body.username,
            name: "\(body.firstName) \(body.lastName ?? "")",
            login: "@\(body.username)",
            bio: body.bio ?? ""
        )
    }
}

struct Profile {
    let username: String
    let name: String
    let login: String
    let bio: String
}

extension ProfileService {
    
    private struct ProfileBody: Decodable {
        let username: String
        let firstName: String
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
}
