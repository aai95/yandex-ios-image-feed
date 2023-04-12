import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let animation = TimeInterval(2)
    private let network = TimeInterval(5)
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testUserAuthorization() throws {
        // FIXME: Set user e-mail and password to pass this test
        let userEmail = "your_email"
        let userPassword = "your_password"
        
        let authButton = app.buttons["Authorize"]
        XCTAssertTrue(authButton.waitForExistence(timeout: animation))
        authButton.tap()
        
        let loginPage = app.webViews["LoginPage"]
        XCTAssertTrue(loginPage.waitForExistence(timeout: network))
        
        let emailField = loginPage.descendants(matching: .textField).firstMatch
        emailField.tap()
        emailField.typeText(userEmail)
        
        let passwordField = loginPage.descendants(matching: .secureTextField).firstMatch
        passwordField.tap()
        passwordField.typeText(userPassword)
        
        loginPage.buttons["Login"].tap()
        XCTAssertTrue(app.tables.children(matching: .cell).firstMatch.waitForExistence(timeout: network))
    }
    
    func testImageFeedInteraction() throws {
        let cell = app.tables.children(matching: .cell).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: network))
        cell.swipeUp()
        
        cell.buttons["LikeOff"].tap()
        XCTAssert(cell.buttons["LikeOn"].waitForExistence(timeout: network))
        cell.buttons["LikeOn"].tap()
        XCTAssert(cell.buttons["LikeOff"].waitForExistence(timeout: network))
        
        cell.tap()
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: network))
        image.pinch(withScale: 2, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["Back"].tap()
        XCTAssertTrue(app.tables.children(matching: .cell).firstMatch.waitForExistence(timeout: animation))
    }
    
    func testProfileInteraction() throws {
        XCTAssertTrue(app.tables.children(matching: .cell).firstMatch.waitForExistence(timeout: network))
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.images["Profile"].exists)
        XCTAssertTrue(app.staticTexts["Name"].exists)
        XCTAssertTrue(app.staticTexts["Login"].exists)
        
        app.buttons["Logout"].tap()
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: animation))
        alert.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.buttons["Authorize"].waitForExistence(timeout: animation))
    }
}
