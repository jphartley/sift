import XCTest

final class siftUITests: XCTestCase {
    func testAppLaunchesAndShowsTabs() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Record"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["History"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Privacy"].waitForExistence(timeout: 5))
    }

    func testHistoryTabLoads() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
    }

    func testPrivacyTabLoads() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Privacy"].tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["What happens when you record"].waitForExistence(timeout: 5))
    }
}
