import XCTest

final class siftUITests: XCTestCase {
    func testAppLaunchesAndShowsTabs() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Record"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["History"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Privacy"].waitForExistence(timeout: 5))
    }

    func testHistoryTabLoads() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["History"].tap()
        XCTAssertTrue(app.staticTexts["History"].waitForExistence(timeout: 5))
    }

    func testPrivacyTabLoads() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Privacy"].tap()
        XCTAssertTrue(app.staticTexts["Your voice stays here."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Transcribed on your phone"].waitForExistence(timeout: 5))
    }
}
