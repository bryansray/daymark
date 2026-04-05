import Core
import XCTest

final class DateParserTests: XCTestCase {
    func testParsesISO8601DateTime() throws {
        let date = try DateParser.parse("2026-04-04T10:30:00Z")
        XCTAssertEqual(date.timeIntervalSince1970, 1_775_298_600)
    }

    func testParsesCalendarDate() throws {
        let date = try DateParser.parse("2026-04-04")
        XCTAssertGreaterThan(date.timeIntervalSince1970, 0)
    }

    func testRejectsInvalidDates() {
        XCTAssertThrowsError(try DateParser.parse("banana")) { error in
            XCTAssertEqual(error as? DaymarkError, .invalidDate("banana"))
        }
    }
}
