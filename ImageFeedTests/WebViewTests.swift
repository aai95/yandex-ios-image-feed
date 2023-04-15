import XCTest
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var controller: WebViewViewControllerProtocol?
    var isViewDidLoadCalled = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func extractCode(from url: URL) -> String? {
        return nil
    }
    
    func didUpdateProgress(with value: Float) {}
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    var isLoadByRequestCalled = false
    
    func load(by request: URLRequest) {
        isLoadByRequestCalled = true
    }
    
    func setProgress(value: Float) {}
    func setProgress(isHidden: Bool) {}
}

final class WebViewTests: XCTestCase {
    
    func testControllerCallsViewDidLoad() {
        // Given
        let webPresenterSpy = WebViewPresenterSpy()
        let webController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        webPresenterSpy.controller = webController
        webController.presenter = webPresenterSpy
        
        // When
        _ = webController.view
        
        // Then
        XCTAssertTrue(webPresenterSpy.isViewDidLoadCalled)
    }
    
    func testPresenterCallsLoadByRequest() {
        // Given
        let webPresenter = WebViewPresenter(authHelper: AuthHelper())
        let webControllerSpy = WebViewViewControllerSpy()
        
        webPresenter.controller = webControllerSpy
        webControllerSpy.presenter = webPresenter
        
        // When
        webPresenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(webControllerSpy.isLoadByRequestCalled)
    }
    
    func testProgressIsVisibleWhenLessThanOne() {
        // Given
        let webPresenter = WebViewPresenter(authHelper: AuthHelper())
        
        // When
        let isHidden = webPresenter.shouldHideProgress(for: 0.9)
        
        // Then
        XCTAssertFalse(isHidden)
    }
    
    func testProgressIsHiddenWhenEqualsOne() {
        // Given
        let webPresenter = WebViewPresenter(authHelper: AuthHelper())
        
        // When
        let isHidden = webPresenter.shouldHideProgress(for: 1.0)
        
        // Then
        XCTAssertTrue(isHidden)
    }
    
    func testAuthLinkContainsExpectedParameters() {
        // Given
        let authHelper = AuthHelper()
        
        // When
        let authLink = authHelper.makeAuthURL().absoluteString
        
        // Then
        XCTAssertTrue(authLink.contains(defaultAuthConfig.baseURL.absoluteString))
        XCTAssertTrue(authLink.contains(defaultAuthConfig.clientID))
        XCTAssertTrue(authLink.contains(defaultAuthConfig.redirectURI))
        XCTAssertTrue(authLink.contains(defaultAuthConfig.responseType))
        XCTAssertTrue(authLink.contains(defaultAuthConfig.scope))
    }
    
    func testAuthCodeExtractedFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://example.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test_code_value")]
        
        // When
        let code = AuthHelper().extractCode(from: urlComponents.url!)
        
        // Then
        XCTAssertEqual(code, "test_code_value")
    }
}
