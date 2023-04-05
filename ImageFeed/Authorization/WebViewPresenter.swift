import Foundation

protocol WebViewPresenterProtocol {
    var controller: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func extractCode(from url: URL) -> String?
    func didUpdateProgress(with value: Float)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var controller: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to init URLComponents with url \(baseURL)")
        }
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        guard let authURL = urlComponents.url else {
            preconditionFailure("Failed to get URL from URLComponents")
        }
        didUpdateProgress(with: 0.0)
        controller?.load(by: URLRequest(url: authURL))
    }
    
    func extractCode(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let item = urlComponents.queryItems?.first(where: { $0.name == "code" })
        {
            return item.value
        } else {
            return nil
        }
    }
    
    func didUpdateProgress(with value: Float) {
        controller?.setProgress(value: value)
        controller?.setProgress(isHidden: shouldHideProgress(for: value))
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        return abs(value - 1.0) <= 0.001
    }
}
