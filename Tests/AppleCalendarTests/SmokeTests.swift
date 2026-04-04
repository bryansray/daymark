import AppleCalendar
import XCTest

final class SmokeTests: XCTestCase {
    func testProviderCanBeConstructed() {
        let provider = AppleCalendarProvider()
        XCTAssertFalse(provider.authorizationStatus().rawValue.isEmpty)
    }
}
