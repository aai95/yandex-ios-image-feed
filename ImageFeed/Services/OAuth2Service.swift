import Foundation

final class OAuth2Service {
    
    private let storage = OAuth2TokenStorage()
    
    private (set) var authToken: String? {
        get {
            return storage.token
        }
        set {
            storage.token = newValue
        }
    }
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = authTokenRequest(code: code)
        let task = decodeStruct(from: request) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
    
    private func decodeStruct(
        from request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        return URLSession.shared.makeTask(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
}
