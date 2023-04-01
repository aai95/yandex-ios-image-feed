import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

extension URLRequest {
    
    static func makeHTTPRequest(
        base: URL = baseAPIURL,
        path: String,
        method: HTTPMethod = .get
    ) -> URLRequest {
        guard let url = URL(string: path, relativeTo: base) else {
            preconditionFailure("Failed to init URL with path \(path) relative to base \(base)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
