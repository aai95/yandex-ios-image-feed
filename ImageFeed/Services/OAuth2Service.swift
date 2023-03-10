import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let storage = OAuth2TokenStorage.shared
    private let session = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return storage.token
        }
        set {
            storage.token = newValue
        }
    }
    
    private var lastTask: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            return
        }
        lastTask?.cancel()
        lastCode = code
        
        let request = makeTokenRequest(code)
        let task = session.decodeTask(from: request) { [weak self] (result: Result<TokenBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let token = body.accessToken
                self.authToken = token
                completion(.success(token))
                self.lastTask = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            }
        }
        
        lastTask = task
        task.resume()
    }
    
    private func makeTokenRequest(_ code: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            base: URL(string: "https://unsplash.com")!,
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&client_secret=\(secretKey)"
            + "&redirect_uri=\(redirectURI)"
            + "&code=\(code)"
            + "&grant_type=authorization_code",
            method: .post
        )
    }
}

extension OAuth2Service {
    
    private struct TokenBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}
