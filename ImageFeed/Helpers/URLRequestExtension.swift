import Foundation

extension URLRequest {
    
    static func makeHTTPRequest(path: String, method: String, base: URL = defaultBaseURL) -> URLRequest {
        guard let url = URL(string: path, relativeTo: base) else {
            fatalError("Failed to init URL with path \(path) relative to base \(base)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}
