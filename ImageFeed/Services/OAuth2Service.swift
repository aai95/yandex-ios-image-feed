import Foundation

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    
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
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            return
        }
        lastTask?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = urlSession.decodeTask(from: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.lastTask = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            }
        }
        
        lastTask = task
        task.resume()
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&client_secret=\(secretKey)"
            + "&redirect_uri=\(redirectURI)"
            + "&code=\(code)"
            + "&grant_type=authorization_code",
            method: "POST",
            base: URL(string: "https://unsplash.com")!
        )
    }
}

extension OAuth2Service {
    
    private struct OAuthTokenResponseBody: Decodable {
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
