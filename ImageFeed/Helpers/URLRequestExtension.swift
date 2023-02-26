import Foundation

extension URLRequest {
    
    static func createHTTPRequest(path: String, method: String, base: URL = DefaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: base)!)
        request.httpMethod = method
        return request
    }
}
