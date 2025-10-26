//
//  BaseUITestCase.swift
//  MacroLensUITests
//
//  Path: MacroLensUITests/Helpers/BaseUITestCase.swift
//
//  PURPOSE:
//  - Base class for all UI tests
//  - App launch configuration
//  - Common UI interaction helpers
//  - Screenshot utilities
//  - Wait helpers
//

import XCTest

/// Base UI test case class with common functionality
class BaseUITestCase: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    /// Timeout for UI elements
    var timeout: TimeInterval = 10.0
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Launch app
        app = XCUIApplication()
        setupLaunchArguments()
        setupLaunchEnvironment()
        app.launch()
    }
    
    override func tearDown() {
        // Take screenshot on failure
        if testRun?.hasSucceeded == false {
            takeScreenshot(name: "Failure-\(name)")
        }
        
        app.terminate()
        app = nil
        
        super.tearDown()
    }
    
    // MARK: - Launch Configuration
    
    /// Setup launch arguments
    func setupLaunchArguments() {
        app.launchArguments = [
            "-UITestMode", "YES",
            "-SkipOnboarding", "YES",
            "-UseMockData", "YES"
        ]
    }
    
    /// Setup launch environment
    func setupLaunchEnvironment() {
        app.launchEnvironment = [
            "IS_UI_TESTING": "1",
            "ANIMATIONS_ENABLED": "0" // Disable animations for faster tests
        ]
    }
    
    // MARK: - Wait Helpers
    
    /// Wait for element to exist
    /// - Parameters:
    ///   - element: Element to wait for
    ///   - timeout: Timeout in seconds
    /// - Returns: True if element exists within timeout
    @discardableResult
    func waitForExistence(of element: XCUIElement, timeout: TimeInterval? = nil) -> Bool {
        return element.waitForExistence(timeout: timeout ?? self.timeout)
    }
    
    /// Wait for element to disappear
    /// - Parameters:
    ///   - element: Element to wait for
    ///   - timeout: Timeout in seconds
    /// - Returns: True if element disappears within timeout
    @discardableResult
    func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval? = nil) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout ?? self.timeout)
        return result == .completed
    }
    
    /// Wait for element to be hittable
    /// - Parameters:
    ///   - element: Element to wait for
    ///   - timeout: Timeout in seconds
    /// - Returns: True if element is hittable within timeout
    @discardableResult
    func waitForHittable(_ element: XCUIElement, timeout: TimeInterval? = nil) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout ?? self.timeout)
        return result == .completed
    }
    
    // MARK: - Interaction Helpers
    
    /// Tap element if it exists
    /// - Parameter element: Element to tap
    func tapIfExists(_ element: XCUIElement) {
        if waitForExistence(of: element, timeout: 2.0) {
            element.tap()
        }
    }
    
    /// Type text into element
    /// - Parameters:
    ///   - text: Text to type
    ///   - element: Element to type into
    func typeText(_ text: String, into element: XCUIElement) {
        waitForExistence(of: element)
        element.tap()
        element.typeText(text)
    }
    
    /// Clear text from element and type new text
    /// - Parameters:
    ///   - element: Element to clear
    ///   - text: New text to type
    func clearAndTypeText(_ element: XCUIElement, text: String) {
        waitForExistence(of: element)
        element.tap()
        
        // Select all and delete
        if let stringValue = element.value as? String, !stringValue.isEmpty {
            element.tap()
            element.doubleTap() // Select all
            app.keys["delete"].tap()
        }
        
        element.typeText(text)
    }
    
    /// Scroll to element
    /// - Parameters:
    ///   - element: Element to scroll to
    ///   - scrollView: Scroll view containing the element
    func scrollTo(_ element: XCUIElement, in scrollView: XCUIElement) {
        while !element.isHittable && scrollView.exists {
            scrollView.swipeUp()
        }
    }
    
    /// Pull to refresh
    /// - Parameter scrollView: Scroll view to refresh
    func pullToRefresh(_ scrollView: XCUIElement) {
        let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
    
    // MARK: - Assertion Helpers
    
    /// Assert element exists
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Failure message
    func assertExists(_ element: XCUIElement, _ message: String = "Element should exist") {
        XCTAssertTrue(waitForExistence(of: element), message)
    }
    
    /// Assert element does not exist
    /// - Parameters:
    ///   - element: Element to check
    ///   - message: Failure message
    func assertNotExists(_ element: XCUIElement, _ message: String = "Element should not exist") {
        XCTAssertFalse(element.exists, message)
    }
    
    /// Assert text field contains text
    /// - Parameters:
    ///   - textField: Text field to check
    ///   - expectedText: Expected text
    func assertTextFieldContains(_ textField: XCUIElement, expectedText: String) {
        XCTAssertEqual(textField.value as? String, expectedText)
    }
    
    /// Assert button is enabled
    /// - Parameters:
    ///   - button: Button to check
    ///   - message: Failure message
    func assertButtonEnabled(_ button: XCUIElement, _ message: String = "Button should be enabled") {
        XCTAssertTrue(button.isEnabled, message)
    }
    
    /// Assert button is disabled
    /// - Parameters:
    ///   - button: Button to check
    ///   - message: Failure message
    func assertButtonDisabled(_ button: XCUIElement, _ message: String = "Button should be disabled") {
        XCTAssertFalse(button.isEnabled, message)
    }
    
    // MARK: - Navigation Helpers
    
    /// Navigate to tab
    /// - Parameter tabName: Tab name
    func navigateToTab(_ tabName: String) {
        let tabBar = app.tabBars.firstMatch
        let tab = tabBar.buttons[tabName]
        waitForExistence(of: tab)
        tab.tap()
    }
    
    /// Tap back button
    func tapBackButton() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        waitForExistence(of: backButton)
        backButton.tap()
    }
    
    /// Dismiss modal by tapping X button
    func dismissModal() {
        let closeButton = app.buttons["xmark"]
        if waitForExistence(of: closeButton, timeout: 2.0) {
            closeButton.tap()
        }
    }
    
    // MARK: - Screenshot Helpers
    
    /// Take screenshot
    /// - Parameter name: Screenshot name
    func takeScreenshot(name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
    
    /// Take screenshot of specific element
    /// - Parameters:
    ///   - element: Element to capture
    ///   - name: Screenshot name
    func takeScreenshot(of element: XCUIElement, name: String) {
        let screenshot = XCTAttachment(screenshot: element.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
    
    // MARK: - Common UI Elements
    
    /// Get text field by placeholder
    /// - Parameter placeholder: Placeholder text
    /// - Returns: Text field element
    func textField(withPlaceholder placeholder: String) -> XCUIElement {
        return app.textFields[placeholder]
    }
    
    /// Get secure text field by placeholder
    /// - Parameter placeholder: Placeholder text
    /// - Returns: Secure text field element
    func secureTextField(withPlaceholder placeholder: String) -> XCUIElement {
        return app.secureTextFields[placeholder]
    }
    
    /// Get button by label
    /// - Parameter label: Button label
    /// - Returns: Button element
    func button(withLabel label: String) -> XCUIElement {
        return app.buttons[label]
    }
    
    /// Get static text by label
    /// - Parameter label: Text label
    /// - Returns: Static text element
    func text(withLabel label: String) -> XCUIElement {
        return app.staticTexts[label]
    }
    
    // MARK: - Alert Helpers
    
    /// Dismiss alert by tapping OK
    func dismissAlert() {
        let alert = app.alerts.firstMatch
        if waitForExistence(of: alert, timeout: 2.0) {
            alert.buttons["OK"].tap()
        }
    }
    
    /// Tap alert button
    /// - Parameter buttonLabel: Button label
    func tapAlertButton(_ buttonLabel: String) {
        let alert = app.alerts.firstMatch
        waitForExistence(of: alert)
        alert.buttons[buttonLabel].tap()
    }
}

// MARK: - Usage Example

/*
 
 class LoginUITests: BaseUITestCase {
     
     func testLoginFlow() {
         // Get elements
         let emailField = textField(withPlaceholder: "Email")
         let passwordField = secureTextField(withPlaceholder: "Password")
         let loginButton = button(withLabel: "Sign In")
         
         // Fill form
         typeText("test@example.com", into: emailField)
         typeText("Password123!", into: passwordField)
         
         // Assert button is enabled
         assertButtonEnabled(loginButton)
         
         // Tap login
         loginButton.tap()
         
         // Wait for home screen
         let homeTab = app.tabBars.buttons["Home"]
         assertExists(homeTab, "Should navigate to home after login")
         
         // Take screenshot
         takeScreenshot(name: "HomeScreen")
     }
 }
 
 */
