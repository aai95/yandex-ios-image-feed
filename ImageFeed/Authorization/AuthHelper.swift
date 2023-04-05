import Foundation

struct AuthConfiguration {
    let baseURL: URL
    let clientID: String
    let redirectURI: String
    let responseType: String
    let scope: String
}

protocol AuthHelperProtocol {
    func makeAuthRequest() -> URLRequest
    func extractCode(from url: URL) -> String?
}

class AuthHelper: AuthHelperProtocol {
    
    private let config: AuthConfiguration
    
    init(authConfig: AuthConfiguration = defaultAuthConfig) {
        self.config = authConfig
    }
    
    func makeAuthRequest() -> URLRequest {
        return URLRequest(url: makeAuthURL())
    }
    
    func makeAuthURL() -> URL {
        guard var urlComponents = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to init URLComponents with url \(config.baseURL)")
        }
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: config.responseType),
            URLQueryItem(name: "scope", value: config.scope)
        ]
        guard let authURL = urlComponents.url else {
            preconditionFailure("Failed to get URL from URLComponents")
        }
        return authURL
    }
    
    func extractCode(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let item = urlComponents.queryItems?.first(where: { $0.name == config.responseType })
        {
            return item.value
        } else {
            return nil
        }
    }
}
