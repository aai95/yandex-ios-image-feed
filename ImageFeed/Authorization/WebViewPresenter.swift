import Foundation

protocol WebViewPresenterProtocol {
    var controller: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func extractCode(from url: URL) -> String?
    func didUpdateProgress(with value: Float)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    private let authHelper: AuthHelperProtocol
    
    weak var controller: WebViewViewControllerProtocol?
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        didUpdateProgress(with: 0.0)
        controller?.load(by: authHelper.makeAuthRequest())
    }
    
    func extractCode(from url: URL) -> String? {
        authHelper.extractCode(from: url)
    }
    
    func didUpdateProgress(with value: Float) {
        controller?.setProgress(value: value)
        controller?.setProgress(isHidden: shouldHideProgress(for: value))
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        return abs(value - 1.0) <= 0.001
    }
}
